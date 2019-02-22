(ns mq.programs.handlers
  (:require [re-frame.core :refer [reg-event-db reg-event-fx]]
            [mq.interceptors :refer [default-interceptors]]
            [com.rpl.specter :as s])
  (:require-macros
    [com.rpl.specter :refer [transform setval]]))

(reg-event-db
  :unzip
  default-interceptors
  (fn [db [program-id result-id content]]
    (setval [:programs s/LAST (s/keypath program-id) :execution-results s/ALL #(= (:id %) result-id) :content]
            content
            db)))



(reg-event-fx
  :download-zip
  (fn [_ [_ zip]]
    {:save-file ["results.zip" (.generateAsync zip #js {:type "blob"})]}))

(reg-event-fx
  :download-file
  (fn [_ [_ file]]
    {:save-file [(.-name file) (.async file "blob")]}))

