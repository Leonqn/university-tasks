(ns graphs.core
  (:require [devtools.core :as devtools]
            [clojure.string :as string]))
(def debug?
  ^boolean js/goog.DEBUG)

(when debug?
  (devtools/enable-feature! :dirac)
  (devtools/install!)
  (enable-console-print!))

(def store (atom {}))
(def points-count (atom 0))

(def charts {:cpu (.generate js/c3 #js {:bindto "#cpu-chart" :data #js {:columns #js []} :line #js {:connectNull true}})
             :ram (.generate js/c3 #js {:bindto "#ram-chart" :data #js {:columns #js []} :line #js {:connectNull true}})})

(def socket (js/WebSocket. (.-wsUrl js/config)))

(defn avg
  ([coll] (avg identity coll))
  ([selector coll]
   (if (nil? coll)
     nil
     (/ (reduce #(+ (selector %2) %1) 0 coll) (count coll)))))

(defn update-store! [x]
  (let [[typ id value] (string/split x #" ")]
    (swap! store update-in [(keyword typ) (keyword id)] (partial cons (js/parseFloat value)))))

(defn get-store-snapshot []
  (->>
    (apply merge-with concat
     (for [[typ ids] @store
           [id vals] ids]
       {typ [[id (avg vals)]]}))
    (map
      (fn [[k vs]]
        [k
         (clj->js
           (cons
             ["avg" (avg (fn [[_ v]] v) vs)]
             vs))]))
    (into {})))

(defn get-charts-start-point []
  (if (> @points-count 20) (- @points-count 20) 0))

(set! (.-onmessage socket) #(update-store! (.-data %)))

(js/setTimeout
  (fn f []
    (let [snp (get-store-snapshot)]
      (reset! store {})
      (swap! points-count inc)
      (doseq [[k v] charts]
        (.flow v #js {:columns (k snp) :to (get-charts-start-point)})))
    (js/setTimeout f 5000))
  0)


(defn on-js-reload [])
