(ns client.core
  (:require [reagent.core :as reagent :refer [atom]]
            [devtools.core :as devtools]))
(def debug?
  ^boolean js/goog.DEBUG)

(when debug?
  (devtools/enable-feature! :dirac)
  (devtools/install!)
  (enable-console-print!))

(def og-meta (atom #js {"Введи" "урлик"}))

(defn convert-meta [x]
  (condp = (str x)
    "NetException" {"Сетевая" "ошибка"}
    "NotFoundException" {"404" "ошибка"}
    "MetaAbsentException" {"Нет меты" "ошибка"}
    "UnknownException" {"Неизвестная" "ошибка"}
    (into {} (for [k (.keys js/Object x)] [(keyword k) (aget x k)]))))

(defn form [service-client]
  (let [url (atom nil)]
    (fn []
      [:div
       [:form
        [:input
         {:type      "text"
          :on-change #(reset! url (-> % .-target .-value))}]
        [:input
         {:type  "submit"
          :on-click
                 (fn [x]
                   (.preventDefault x)
                   (reset! og-meta #js {"Ожидайте" "ответа"})
                   (.GetMeta service-client @url #(reset! og-meta %)))
          :value "click"}]]])))

(defn og-view []
  (let [clj-meta (convert-meta @og-meta)
        flatten-meta (merge (-> clj-meta :additional js->clj) (dissoc clj-meta :additional))]
    [:table
     [:tbody
      (for [[k v] flatten-meta]
        [:tr {:key k}
         [:td (name k)]
         [:td v]])]]))

(defn og []
  (let [Transport (.-Transport js/Thrift)
        Protocol (.-Protocol js/Thrift)
        Client (.-OpenGraphServiceClient js/OpenGraph)
        client (->> (.-apiUrl js/config) (Transport.) (Protocol.) (Client.))]
    (fn []
      [:div
       [form client]
       [og-view]])))


(reagent/render [og] (.getElementById js/document "app"))


(defn on-js-reload [])

