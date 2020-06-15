/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <folly/Logging.h>
#include <string>

#include "hbase/test-util/test-util.h"
#include "hbase/utils/concurrent-map.h"

using hbase::concurrent_map;

TEST(TestConcurrentMap, TestFindAndErase) {
  concurrent_map<std::string, std::string> map{500};

  map.insert(std::make_pair("foo", "bar"));
  auto prev = map.find_and_erase("foo");
  ASSERT_EQ("bar", prev);

  ASSERT_EQ(map.end(), map.find("foo"));
}

HBASE_TEST_MAIN()
