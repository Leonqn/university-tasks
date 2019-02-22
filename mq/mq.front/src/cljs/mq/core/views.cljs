(ns mq.core.views)

(defn- get-page-range [current-page elements-count]
  (->>
    (/ elements-count 20)
    (.ceil js/Math)
    (+ 1)
    (range 1)
    (drop-while #(> current-page (+ % 5)))
    (take-while #(> current-page (- % 5)))))

(defn row-input [{:keys [label id type class]}]
  [:input.form-control {:field type :id id :placeholder label :class class}])

(defn row-text-area [{:keys [label id class]}]
  [:textarea.form-control {:id id :placeholder label :field :textarea :class class}])


(defn paging [current-page elements-count get-url]
  (let [page-range (get-page-range current-page elements-count)]
    [:nav.d-inline-block {:aria-label "Page navigation"}
     [:ul.pagination
      [:li.page-item {:class (when (= current-page (or (apply min page-range) 1))
                               "disabled")}
       [:a.page-link {:href        (get-url (- current-page 1))
                      :arial-label "Previous"}
        [:span {:aria-hidden "true" :dangerouslySetInnerHTML {:__html "&laquo;"}}]
        [:span.sr-only "Previous"]]]
      (for [page-number page-range]
        [:li.page-item {:key   page-number
                        :class (when (= current-page page-number) "active")}
         [:a.page-link {:href (get-url page-number)}
          page-number]])
      [:li.page-item {:class (when (= current-page (or (apply max page-range) 1))
                               "disabled")}
       [:a.page-link {:href       (get-url (+ current-page 1))
                      :aria-label "Next"}

        [:span {:aria-hidden "true" :dangerouslySetInnerHTML {:__html "&raquo;"}}]
        [:span.sr-only "Next"]]]]]))


(defn open-modal-button [button-value modal-id]
  [:button.btn.btn-primary {:data-toggle "modal"
                            :data-target (str "#" modal-id)}
   button-value])

(defn modal-window [title body modal-id]
  [:div.modal.fade {:aria-hidden     true
                    :role            "dialog"
                    :id              modal-id
                    :tab-index       -1
                    :aria-labelledby "modal"}
   [:div.modal-dialog {:role "document"}
    [:div.modal-content
     [:div.modal-header
      [:button.close {:data-dismiss "modal"
                      :aria-label   "close"}
       [:i.fa.fa-times {:aria-hidden true}]]
      [:h4.modal-title
       title]]
     [:div.modal-body
      body]]]])