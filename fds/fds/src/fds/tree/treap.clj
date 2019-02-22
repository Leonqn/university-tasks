(ns fds.tree.treap)


(defn merge [[_ [_ ly] lr :as lt] [_ [_ ry] rr :as rt]]
  (if (or (nil? lt) (nil? rt))
    (or lt rt)
    (if (> ly ry)
      (assoc lt 2 (merge lr rt))
      (assoc rt 0 (merge lt rr)))))

(defn split [[l [x _] r :as t] el]
  (if (nil? t)
    [nil nil]
    (if (<= x el)
      (let [[l' r'] (split r el)] [(assoc t 2 l') r'])
      (let [[l' r'] (split l el)] [l' (assoc t 0 r')]))))

(defn insert [[f t] el]
  (let [[l r] (split t el)
        n [nil [el (f el)] nil]]
    [f (merge (merge l n) r)]))

(defn remove [[f [l [x _] r :as t]] el]
  (if (nil? t)
    ([f t])
    (if (= el x)
      [f (merge l r)]
      [f (assoc r 0 (remove l el) 2 (remove r el))])))

(defn height [[f [l _ r :as t]]]
  (if (nil? t)
    0
    (+ 1 (max (height [f l]) (height [f r])))))

(defn mk-tree [f xs]
  (reduce insert [f nil] xs))




(defn mk-rnds [count] (->> count range (map rand)))

(->>
  [hash #(Math/sin %) #(Math/cos %) rand]
  (map
    #(map
      (fn [_]
        (->> 1000 mk-rnds (mk-tree %) height))
      (range 100)))
  (map #(let [c (count %)
              sorted (sort %)
              max (apply max %)
              min (apply min %)
              avg (double (/ (apply + %) c))
              percentile (fn [x] (->> (* x c) int (nth sorted)))]
         (println (str "Max: " max " Min: " min " Avg: " avg " 99%: " (percentile 0.99) " 95%: " (percentile 0.95))))))
