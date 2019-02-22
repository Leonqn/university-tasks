(ns mq.views
  (:require [re-frame.core :refer [subscribe]]
            [cljs.core.match :refer-macros [match]]
            [mq.auth.views.signin :as auth]
            [mq.auth.views.user :as user]
            [mq.core.views]
            [mq.programs.views.list :as p-list]
            [mq.tasks.views.list :as t-list]
            [mq.programs.views.details :as p-details]
            [mq.main.views :as main]
            [mq.routes :as routes]))


(defn menu-header []
  [:a.navbar-brand {:href (routes/main-page)}
   "Mq"])

(defn menu-items [logged-in?]
  [:ul.nav.navbar-nav
   (when logged-in?
     [:li.nav-item
      [:a.nav-link {:href (routes/programs-list 1)} "Programs"]])
   (when logged-in?
     [:li.nav-item.pull-xs
      [:a.nav-link {:href (routes/tasks-list 1) } "Tasks"]])
   [:li.nav-item.pull-xs
    [:a.nav-link "Forms"]]])


(defn menu [logged-in?]
  [:nav.navbar.navbar-static-top.navbar-dark.bg-inverse
   [menu-header]
   [menu-items logged-in?]
   (if logged-in?
     [user/user-name-menu-container]
     [auth/sign-in-form])])

(defn panels [panel]
  (match panel
         [:programs-list page] [p-list/programs-list-container page nil]
         [:program-details id] [p-details/program-details-container id]
         [:program-add-to-scope id page] [p-list/programs-list-container page id]
         [:tasks-list page] [t-list/tasks-list-container page]
         [:main-page] [main/hello-view]
         :else [:div]))

(defn error-view [error-message]
  [:div (or (get-in error-message [:response :message])
            (:status-text error-message))])

(defn pending-view []
  [:div.pending
   [:div.loader
    [:img {:src "spin.svg"}]]])

(defn main-panel []
  (let [active-panel (subscribe [:active-panel])
        logged-in? (subscribe [:logged-in?])
        error-message (subscribe [:error-message])
        pending? (subscribe [:pending?])]
    (fn []
      [:div
       [:div
        (when @pending? [pending-view])]
       [mq.core.views/modal-window
        "Whoops! Some error occured"
        [error-view @error-message]
        "error-modal"]
       [menu @logged-in?]
       [panels @active-panel]])))
