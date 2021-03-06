/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_UTIL_HASHING_H_
#define FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_UTIL_HASHING_H_

#include <iterator>
#include <type_traits>

namespace firebase {
namespace firestore {
namespace util {

// This is a pretty terrible hash implementation for lack of a better one being
// readily available. It exists as a portability crutch between our existing
// Objective-C code where overriding `-isEqual:` also requires `-hash` and C++
// where `operator==()` can be defined without defining a hash code.
//
// It's based on the recommendation in Effective Java, Item 9, wherein you
// implement composite hashes like so:
//
//     size_t result = first_;
//     result = 31 * result + second_;
//     result = 31 * result + third_;
//     // ...
//     return result;
//
// This is the basis of this implementation because that's what the existing
// Objective-C code mostly does by hand. Using this implementation gets the
// same result by calling
//
//     return util::Hash(first_, second_, /* ..., */ third_);
//
// TODO(wilhuff): Replace this with whatever Abseil releases.

namespace impl {

/**
 * Combines a hash_value with whatever accumulated state there is so far.
 */
inline size_t Combine(size_t state, size_t hash_value) {
  return 31 * state + hash_value;
}

/**
 * Explicit ordering of hashers, allowing SFINAE without all the enable_if
 * cruft.
 *
 * In order we try:
 *   * A Hash() member, if defined and the return type is an integral type
 *   * A std::hash specialization, if available
 *   * A range-based specialization, valid if either of the above hold on the
 *     members of the range.
 *
 * Explicit ordering resolves the ambiguity of the case where a std::hash
 * specialization is available, but the type is also a range for whose members
 * std::hash is also available, e.g. with std::string.
 *
 * HashChoice is a recursive type, defined such that HashChoice<0> is the most
 * specific type with HashChoice<1> and beyond being progressively less
 * specific. This causes the compiler to prioritize the overloads with
 * lower-numbered HashChoice types, allowing compilation to succeed even if
 * multiple specializations match.
 */
template <int I>
struct HashChoice : HashChoice<I + 1> {};

template <>
struct HashChoice<2> {};

template <typename K>
size_t InvokeHash(const K& value);

/**
 * Hashes the given value if it defines a Hash() member.
 *
 * @return The result of `value.Hash()`.
 */
template <typename K>
auto RankedInvokeHash(const K& value, HashChoice<0>) -> decltype(value.Hash()) {
  return value.Hash();
}

/**
 * Hashes the given value if it has a specialization of std::hash.
 *
 * @return The result of `std::hash<K>{}(value)`
 */
template <typename K>
auto RankedInvokeHash(const K& value, HashChoice<1>)
    -> decltype(std::hash<K>{}(value)) {
  return std::hash<K>{}(value);
}

/**
 * Hashes the contents of the given range of values if the value_type of the
 * range can be hashed.
 */
template <typename Range>
auto RankedInvokeHash(const Range& range, HashChoice<2>)
    -> decltype(impl::InvokeHash(*std::begin(range))) {
  size_t result = 0;
  size_t size = 0;
  for (auto&& element : range) {
    ++size;
    result = Combine(result, InvokeHash(element));
  }
  result = Combine(result, size);
  return result;
}

template <typename K>
size_t InvokeHash(const K& value) {
  return RankedInvokeHash(value, HashChoice<0>{});
}

inline size_t HashInternal(size_t state) {
  return state;
}

template <typename T, typename... Ts>
size_t HashInternal(size_t state, const T& value, const Ts&... rest) {
  state = Combine(state, InvokeHash(value));
  return HashInternal(state, rest...);
}

}  // namespace impl

template <typename... Ts>
size_t Hash(const Ts&... values) {
  return impl::HashInternal(0u, values...);
}

}  // namespace util
}  // namespace firestore
}  // namespace firebase

#endif  // FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_UTIL_HASHING_H_
