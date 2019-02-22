(ns mq.interceptors
  (:require
    [re-frame.core :refer [reg-event-db path trim-v after debug]]
    [cljs.spec :as s]
    [mq.config :as c]))


(defn check-and-throw
  "throw an exception if db doesn't match the spec."
  [a-spec db]
  (when-not (s/valid? a-spec db)
    (throw (ex-info (str "spec check failed: " (s/explain-str a-spec db)) {}))))

(def check-spec-interceptor (after (partial check-and-throw :mq.db/db)))

(def default-interceptors [check-spec-interceptor
                           (when c/debug? debug)
                           trim-v])