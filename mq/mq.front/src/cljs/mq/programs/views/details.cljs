(ns mq.programs.views.details
  (:require
    [reagent.core :refer [atom]]
    [re-frame.core :refer [subscribe dispatch]]
    [mq.core.views :refer [row-input paging]]
    [reagent-forms.core :refer [bind-fields]]
    [mq.utils :as u]
    [mq.routes :as routes]))

(defn editor [program-id code]
  [u/code-mirror {:default-value code
                  :on-save   #(dispatch [:api-call :programs/update {:id program-id :code (.getValue %)}])
                             :line-numbers  true}])



(defn scope-list [program-id scope]
  [:ul.list-group.d-inline-block
   (for [{:keys [id name]} scope]
     [:li.d-inline-block.btn.btn-secondary.scope-tab {:key id}
      [:div.d-inline-block
       [:a.d-inline-block {:href (routes/program-details id)} name]
       [:i.fa.fa-times.remove-scope {:aria-hidden true
                                     :on-click    (u/dispatch [:api-call :programs/remove-from-scope program-id id])}]]])
   [:a.btn.btn-secondary.add-to-scope {:href (routes/add-to-scope program-id 1)}
    [:i.fa.fa-plus {:aria-hidden true}]]])

(defn queue-list [tasks]
  [:div.dropdown-menu.dropdown-menu-left {:aria-labelledby "queue"}
   (for [{:keys [id status]} tasks]
     [:div.dropdown-item {:key id}
      (str "#" id ": " status)])
   [:span.sr-only "Toggle Dropdown"]])


(defn result-item [{:keys [id status content] {:keys [started-at completed-at program]} :task}]
  [:div
   [:h7.text-muted (str "#" id " " (u/format-date started-at) " - " (u/format-date completed-at) " ")
    (if (= status "ok")
      [:i.fa.fa-check {:aria-hidden "true"}]
      [:i.fa.fa-times {:aria-hidden "true"}])
    (if content
      [:button.btn.btn-sm.btn-secondary.pull-xs-right {:on-click (u/dispatch [:download-zip content])}
       "Download zip"]
      [:button.btn.btn-sm.btn-secondary.pull-xs-right {:on-click (u/dispatch [:api-call :execution-results/content id program])}
       "Show results"])]
   (when content
     [:ul.list-group.d-inline-block.card-text
      (for [name (.keys js/Object (.-files content))]
        [:li.d-inline-block.btn.btn-secondary
         {:key      name
          :on-click (u/dispatch [:download-file (aget (.-files content) name)])
          :style    {:margin-left "0.2rem"}}
         name])])])

(defn results-list [results]
  [:div
   [:ul.list-group
    [:li.list-group-item
     "Results"]
    (for [result results]
      [:li.list-group-item {:key (:id result)}
       [result-item result]])]])

(defn queue-button [tasks]
  [:div.btn-group
   [:button.btn.btn-secondary
    (str "Queue (" (count tasks) ")")]
   [:button#queue.btn.btn-secondary.dropdown-toggle.dropdown-toggle-split
    {:type          "button"
     :data-toggle   "dropdown"
     :ara-haspopup  true
     :aria-expanded false
     :style         {:margin-right "1rem"}}]
   [queue-list tasks]])


(defn run-button [program-id]
  [:button.btn.btn-secondary {:on-click (u/dispatch [:api-call :programs/run program-id])}
   "Run"])


(defn program-details [{:keys [id name scope code created-at tasks execution-results description]}]
  [:div.container-fluid
   [:div
    [:h2.d-inline-block name]
    [:h6 {:style {:margin-bottom "1rem"}}
     (u/format-date created-at)]
    [:h5 description]]
   [:table {:style {:width "100%" :table-layout "fixed"}}
    [:colgroup
     [:col {:style {:width "70%"}}]
     [:col {:style {:width "30%"}}]]
    [:tbody
     [:tr
      [:td {:style {:vertical-align "top"}}
       [scope-list id scope]
       [editor id code]]
      [:td {:style {:vertical-align "top"}}
       [:div.d-inline-block.scope-tab
        [queue-button tasks]
        [run-button id]]
       [results-list execution-results]]]]]])

(defn program-details-container [program-id]
  (let [programs (subscribe [:programs])
        active-panel (subscribe [:active-panel])]
    (u/pereodical-dispatch #(= [:program-details program-id] @active-panel) [:api-call-async :programs/details program-id] 5000)
    (fn [program-id]
      [program-details (get-in @programs [1 program-id])])))