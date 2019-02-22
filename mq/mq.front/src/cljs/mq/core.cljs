(ns mq.core
  (:require [reagent.core :as reagent]
            [re-frame.core :as re-frame]
            [devtools.core :as devtools]
            [mq.handlers]
            [mq.auth.handlers]
            [mq.programs.handlers]
            [mq.fxs]
            [mq.subs]
            [mq.api]
            [mq.config :as config]
            [mq.views :as views]
            [day8.re-frame.http-fx]
            [secretary.core :as secretary]
            [mq.routes :as routes]))


(defn dev-setup []
  (when config/debug?
    (enable-console-print!)
    (println "dev mode")
    (devtools/install!)))

(defn mount-root []
  (reagent/render [views/main-panel]
                  (.getElementById js/document "app")))

(defn ^:export init []
  (routes/app-routes)
  (re-frame/dispatch-sync [:initialize-db])
  (secretary/dispatch! (.-hash js/location))
  (dev-setup)
  (mount-root))
