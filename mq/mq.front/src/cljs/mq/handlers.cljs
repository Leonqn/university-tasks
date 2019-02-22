(ns mq.handlers
  (:require [re-frame.core :as re-frame]
            [mq.db :as db]
            [mq.routes :as routes]
            [mq.interceptors :refer [default-interceptors]]))

(re-frame/reg-event-fx
  :initialize-db
  [(re-frame/inject-cofx :<-local-store "creds")]
  (fn [{:keys [<-local-store]} _]
    {:db
     (if (nil? <-local-store)
       db/default-db
       (assoc db/default-db :creds <-local-store))}))


(re-frame/reg-event-fx
  :set-active-panel
  default-interceptors
  (fn [{:keys [db]} [active-panel]]
    (if (:creds db)
      {:db (assoc db :active-panel active-panel)}
      {:db (assoc db :active-panel [:main-page])
       :nav (routes/main-page)})))

