(ns mq.fxs
  (:require [re-frame.core :refer [reg-fx reg-cofx dispatch]]
            [mq.routes :as r]
            [cljs.reader]
            [mq.utils :as u]))

(reg-fx
  :nav
  (fn [val]
    (r/nav! val)))

(reg-fx
  :unzip
  (fn [{:keys [hex-string on-success on-failure]}]
    (u/hex->zip hex-string
                #(dispatch (conj on-success %))
                #(dispatch (conj on-failure %)))))

(reg-fx
  :save-file
  (fn [[file-name promise]]
    (.then promise (fn [content] (js/saveAs content file-name)))))



(reg-fx
  :->local-store
  (fn [[key value]]
    (.setItem js/localStorage key (str value))))

(reg-cofx
  :<-local-store
  (fn [cofx key]
    (assoc cofx :<-local-store
      (some->>
        (.getItem js/localStorage key)
        (cljs.reader/read-string)))))

(reg-fx
  :open-modal
  (fn [modal-id]
    (->
      (str "#" modal-id)
      js/$
      (.modal "show"))))