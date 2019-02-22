(ns mq.programs.views.list
  (:require
    [reagent.core :refer [atom]]
    [re-frame.core :refer [subscribe dispatch]]
    [mq.core.views :refer [row-input paging open-modal-button modal-window row-text-area]]
    [reagent-forms.core :refer [bind-fields]]
    [mq.utils :as u]
    [mq.routes :as routes]
    [clojure.string :as string]))

(def filter-form-template
  (row-input {:label "Program name" :id :name :type :text :class "filter-input"}))

(def add-program-form-template
  [:div
   (row-input {:label "Program name" :id :name :type :text})
   (row-text-area {:label "Description" :id :description})])

(defn scope-buttons [program current-program]
  [:button.btn.btn-primary.pull-xs-left
   {:on-click (u/dispatch [:api-call :programs/add-to-scope (:id current-program) program])
    :disabled (or (= (:id current-program) (:id program))
                  (some #(= (:id program) (:id %)) (:scope current-program)))}
   [:i.fa.fa-plus {:aria-hidden true}]])

(defn delete-program-button [program-id]
  [:button.btn.btn-danger {:type         :submit
                           ;;need to dismis modal, dont know how to do it better
                           :data-dismiss "modal"
                           :on-click     (u/dispatch [:api-call :programs/delete program-id])}
   "Delete"])

(defn program-preview [{:keys [id name code created-at description] :as program} current-program]
  [:div.card.card-block
   [:div {:style {:overflow "hidden"}}
    [:div
     [:h4.card-title.d-inline-block name]
     (when-not current-program
       [:div.pull-xs-right
        [modal-window "Are you sure?" [delete-program-button id] (str "delete" id)]
        [open-modal-button
         [:i.fa.fa-times {:aria-hidden true}]
         (str "delete" id)]])]
    [:h7.card-subtitle.text-muted (u/format-date created-at)]
    [:div.card-text {:style {:height "100px"}}
     (or
       description
       [u/code-mirror {:read-only     "nocursor"
                       :default-value code}])]]
   (when current-program
     [scope-buttons program current-program])
   [:a.btn.btn-primary.pull-xs-right {:href (routes/program-details id)}
    [:i.fa.fa-ellipsis-h {:aria-hidden "true"}]]])

(defn filter-form [page]
  (let [filter (atom {:name ""})]
    (fn []
      [:form.filter-input.d-inline-block
       [bind-fields
        filter-form-template
        filter
        (fn [_ filter-value _]
          (dispatch [:api-call :programs/list page filter-value]))]])))

(defn add-program-form []
  (let [name-and-desc (atom {:name "" :description nil})]
    (fn []
      [:form
       [:div.form-group
        [bind-fields
         add-program-form-template
         name-and-desc]]
       [:button.btn.btn-primary {:type         :submit
                                 ;;need to dismis modal, dont know how to do it better
                                 :data-dismiss "modal"
                                 :on-click     (u/dispatch [:api-call :programs/add @name-and-desc])
                                 :disabled     (string/blank? (:name @name-and-desc))}
        "Add"]])))

(defn programs-grid [programs current-program-id]
  [:div.row
   (for [[id program] programs]
     [:div.col-lg-4.col-md-5.col-xs-6 {:key id}
      [program-preview program (programs current-program-id)]])])

(defn programs-list [page [programs-count programs] current-program-id]
  [:div.container-fluid
   [:div
    [:h2 "Programs"]
    [:div.pull-xs-right
     (when-not current-program-id
       [:div
        [open-modal-button [:i.fa.fa-plus {:aria-hidden true}] "add-program"]
        [modal-window "Create program" [add-program-form] "add-program"]])]]
   [:div.d-inline-block
    [filter-form page]
    [paging page programs-count (if current-program-id
                                  (partial routes/add-to-scope current-program-id)
                                  routes/programs-list)]]
   [programs-grid programs current-program-id]])

(defn programs-list-container [page current-program-id]
  (let [programs (subscribe [:programs])]
    (fn [page current-program-id]
      [programs-list page @programs current-program-id])))