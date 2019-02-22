(ns fds.calc)

(def p {+   1
        -   1
        *   2
        /   2
        nil 0
        \(  0})

(defn reduce-exp [[[fst-fn & rest-fns :as fns] [x y & rest-ops :as ops]] el]
  (cond
    (number? el) [fns (cons el ops)]
    (= \( el) [(cons el fns) ops]
    (= \) el) ((fn [[fst-fn & rest-fns] [x y & rest-ops :as ops]]
                 (if (= fst-fn \()
                   [rest-fns ops]
                   (recur rest-fns (cons (fst-fn y x) rest-ops))))
               fns ops)
    (p el) (if (> (p el) (p fst-fn))
             [(cons el fns) ops]
             [(cons el rest-fns) (cons (fst-fn y x) rest-ops)])
    :else (throw (Exception. (str "Unknown token " el)))))

(defn calc [& args]
  (-> (reduce reduce-exp ['() '()] (flatten [\( args \)])) (nth 1) first))

;example usage (calc 1 + 2 * 2 + \( 2 + 3 \))