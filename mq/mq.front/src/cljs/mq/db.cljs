(ns mq.db
  (:require [cljs.reader]
            [mq.core.db]
            [mq.programs.db]
            [mq.auth.db]
            [mq.tasks.db]
            [cljs.spec :as s]))

(s/def ::db (s/keys :req-un [:mq.core.db/pending?
                             :mq.core.db/active-panel
                             :mq.programs.db/programs
                             :mq.tasks.db/tasks]
                    :opt-un [:mq.core.db/error-message
                             :mq.auth.db/creds]))

(def default-db
  {:pending?     false
   :active-panel :programs-list
   :programs     [0 {}]
   :forms        [0 {}]
   :tasks        [0 {}]})
