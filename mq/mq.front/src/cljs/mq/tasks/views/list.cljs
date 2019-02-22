(ns mq.tasks.views.list
  (:require
    [mq.routes :as routes]
    [mq.core.views :refer [paging]]
    [re-frame.core :refer [subscribe]]
    [mq.utils :as u]))

(defn task-info [])


(defn tasks-table [tasks]
  [:table.table
   [:thead
    [:tr
     [:th "Id"]
     [:th "Runned by"]
     [:th "Created at"]
     [:th "Started at"]
     [:th "Status"]
     [:th "Source"]]]
   [:tbody
    (for [[_ {:keys [id created-at started-at author program status]}] tasks]
      [:tr {:key id}
       [:td id]
       [:td author]
       [:td (u/format-date created-at)]
       [:td (if started-at
              (u/format-date started-at)
              "Not yet started")]
       [:td status]
       [:td
        [:a {:href (routes/program-details (:id program))}
         (:name program)]]])]])



(defn tasks-list [page [tasks-count tasks]]
  [:div.container-fluid
   [:h2 "Tasks"]
   [:div.d-inline-block
    [paging page tasks-count routes/tasks-list]]
   [tasks-table tasks]])

(defn tasks-list-container [page]
  (let [tasks (subscribe [:tasks])
        active-panel (subscribe [:active-panel])]
    (u/pereodical-dispatch #(= :tasks-list (@active-panel 0)) [:api-call-async :tasks/list] 5000)
    (fn [page]
      [tasks-list page @tasks])))