(ns mq.runner
    (:require [doo.runner :refer-macros [doo-tests]]
              [mq.core-test]
              [cljs.test :as test]))

(doo-tests 'mq.core-test)
