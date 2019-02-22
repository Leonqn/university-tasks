(ns mq.api-test
  (:require [cljs.test :refer-macros [deftest testing is use-fixtures]]
    [mq.api :as api]))

(defn fixture-re-frame
  []
  (let [restore-re-frame (atom nil)]
    {:before #(reset! restore-re-frame (re-frame.core/make-restore-fn))
     :after  #(@restore-re-frame)}))

(use-fixtures :each (fixture-re-frame))


