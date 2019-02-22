(ns mq.programs.db
  (:require [cljs.spec :as s]))

(s/def ::name string?)
(s/def ::code string?)
(s/def ::status #{"ok" "failed"})
(s/def ::content object?)
(s/def ::description (s/nilable string?))
(s/def ::scope (s/coll-of ::program))
(s/def ::task (s/keys :req-un [:mq.core.db/id
                               :mq.tasks.db/status
                               :mq.tasks.db/started-at
                               :mq.tasks.db/completed-at]))
(s/def ::execution-result (s/keys :req-un [:mq.core.db/id
                                           ::task
                                           ::status]
                                  :opt-un [::content]))
(s/def ::program (s/keys :req-un [:mq.core.db/id
                                  :mq.auth.db/author
                                  :mq.core.db/created-at
                                  ::code
                                  ::name
                                  ::description]
                         :opt-un [::execution-results
                                  ::tasks
                                  ::scope]))

(s/def ::tasks (s/coll-of ::task))
(s/def ::execution-results (s/coll-of ::execution-result))

(s/def ::programs (s/tuple :mq.core.db/size (s/map-of :mq.core.db/id ::program)))
