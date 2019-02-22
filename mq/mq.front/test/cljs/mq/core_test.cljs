(ns mq.core-test
  (:require [cljs.test :refer-macros [deftest testing is]]
            [mq.core :as core]))

(deftest test-numbers
  (is (= 1 1)))