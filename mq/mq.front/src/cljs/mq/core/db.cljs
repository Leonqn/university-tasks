(ns mq.core.db
  (:require [cljs.spec :as s]))

(s/def ::id int?)
(s/def ::created-at #(-> (js/Date. %) .getTime js/isNaN not))
(s/def ::started-at ::created-at)
(s/def ::completed-at ::created-at)
(s/def ::error-message #(-> true))
(s/def ::pending? (s/nilable boolean?))
(s/def ::size int?)
(s/def ::active-panel #(-> true))
