(ns mq.auth.handlers
  (:require [re-frame.core :refer [reg-event-fx]]
            [mq.interceptors :refer [default-interceptors]]
            [mq.db :as db]))

(reg-event-fx
  :signout
  default-interceptors
  (fn [_ _]
    {:db db/default-db
     :->local-store ["creds" nil]}))