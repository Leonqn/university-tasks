(ns mq.subs
    (:require-macros [reagent.ratom :refer [reaction]])
    (:require [re-frame.core :refer [reg-sub]]))

(reg-sub
 :active-panel
 (fn [db _]
   (:active-panel db)))

(reg-sub
  :author
  (fn [db _]
    (get-in db [:creds :author])))

(reg-sub
  :token
  (fn [db _]
    (get-in db [:creds :token])))

(reg-sub
  :logged-in?
  (fn [db _]
    (some? (:creds db))))

(reg-sub
  :programs
  (fn [db _]
    (:programs db)))

(reg-sub
  :tasks
  (fn [db _]
    (:tasks db)))

(reg-sub
  :error-message
  (fn [db _]
    (:error-message db)))

(reg-sub
  :pending?
  (fn [db _]
    (:pending? db)))