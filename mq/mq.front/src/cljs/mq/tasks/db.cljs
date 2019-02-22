(ns mq.tasks.db
  (:require [cljs.spec :as s]))

(s/def ::status #{"executing" "free" "completed"})

(s/def ::program (s/keys :req-un [:mq.core.db/id :mq.programs.db/name]))

(s/def ::task (s/keys :req-un [:mq.core.db/id
                               :mq.auth.db/author
                               :mq.core.db/created-at
                               ::status]
                      :opt-un [:mq.core.db/started-at
                               :mq.core.db/completed-at
                               ::program]))


(s/def ::tasks (s/tuple :mq.core.db/size (s/map-of :mq.core.db/id ::task)))
