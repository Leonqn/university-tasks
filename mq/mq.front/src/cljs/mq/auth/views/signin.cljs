(ns mq.auth.views.signin
  (:require [reagent-forms.core :refer [bind-fields]]
            [reagent.core :refer [atom]]
            [clojure.string :as s]
            [mq.utils :refer [dispatch not-every-nil?]]
            [mq.core.views :refer [row-input]]))


(defmulti validate identity)

(defmethod validate :email [_ email]
  (cond
    (s/blank? email) "Email should not be empty"
    (not (s/includes? email "@")) "Email should contain @"
    :else nil))

(defmethod validate :password [_ password]
  (cond
    (s/blank? password) "Password should not be empty"
    (->> password count (> 6)) "Password length should be greater than 6"
    (->> password count (< 50)) "Password length should be less than 50"
    :else nil))

(defmethod validate :default [_] nil)

(def sign-in-template
  [:div {:style {:display "inline"}}
   (row-input {:label "Email" :id :email :type :email :class "cred-input"})
   (row-input {:label "Password" :id :password :type :password :class "cred-input"})])

(defn sign-in-button [disabled?]
  [:button.btn.btn-success {:type :submit :disabled disabled?}
   "Sign in"])

(defn sign-in-form []
  (let [cred (atom {:email nil :password nil :errors {:email "" :password ""}})]
    (fn []
      [:form.form-inline.pull-xs-right
       {:on-submit   (dispatch [:api-call :auth/signin (dissoc @cred :errors)])
        :no-validate true}
       [bind-fields sign-in-template cred
        (fn [[id] val doc]
          (assoc-in doc [:errors id] (validate id val)))]
       [sign-in-button (not-every-nil? (:errors @cred))]])))
