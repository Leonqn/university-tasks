(ns mq.auth.db
  (:require [cljs.spec :as s]))

(s/def ::token string?)
(s/def ::author string?)

(s/def ::creds (s/keys :req-un [::token ::author]))

