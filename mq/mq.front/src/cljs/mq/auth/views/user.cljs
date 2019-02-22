(ns mq.auth.views.user
  (:require [re-frame.core :as rf]
            [mq.utils :as u]))

(defn user-name-menu [name]
  [:div.pull-xs-right
   [:a.nav-link.cred-input name]
   [:button.btn.btn-success {:on-click (u/dispatch [:signout])}
    "Sign out"]])

(defn user-name-menu-container []
  (let [author (rf/subscribe [:author])]
    [user-name-menu @author]))
