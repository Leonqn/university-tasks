(ns fds.tree.delete)

(defn delete [[l x r :as t] el]
  (let [find-min-value (fn [[l x _]] (if (nil? l) x (recur l)))]
    (cond
      (nil? x) t
      (= el x) (if (or (nil? l) (nil? r))
                 (or l r)
                 (let [min-value (find-min-value r)]
                   [l min-value (delete r min-value)]))
      (< el x) [(delete l el) x r]
      (>= el x) [l x (delete r el)])))

(defn p [tree]
  ((fn p' [indents [l x r]]
     (when-not (nil? x)
       (do
         (println (str indents x))
         (p' (str "-" indents) l)
         (p' (str "-" indents) r))))
   "-" tree))