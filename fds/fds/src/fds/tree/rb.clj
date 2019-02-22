(ns fds.tree.rb
  (:require [clojure.core.match :refer [match]]))

(defn balance [t]
  (match [t]
         [(:or
            [:b [:r [:r x a b] y c] z d]
            [:b  [:r a x [:r b y c]] z d]
            [:b a x [:r [:r b y c] z d]]
            [:b a x [:r b y [:r c z d]]])] [:r [:b a x b] y [:b c z d]]
         :else t))

(defn insert [t el]
  (assoc
    ((fn insert' [[c l x r]]
      (cond
        (nil? x) [:r nil el nil]
        (< el x) (balance [c (insert' l) x r])
        (>= el x) (balance [c l x (insert' r)])))
     t)
    0 :b))

(defn p [t]
  ((fn p' [indents [c l x r]]
    (when-not (nil? x)
      (do
        (println (str indents x c))
        (p' (str "-" indents) l)
        (p' (str "-" indents) r))))
   "-" t))