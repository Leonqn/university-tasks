(ns mq.api
  (:require [ajax.core :as ajax]
            [clojure.string :as str]
            [re-frame.core :refer [reg-event-fx reg-event-db]]
            [mq.interceptors :refer [default-interceptors]]
            [cljs.core.match :refer-macros [match]]
            [mq.routes :as routes]
            [com.rpl.specter :as s]
            [mq.utils :as u]
            [clojure.string :as string])
  (:require-macros [com.rpl.specter :refer [transform setval]]))

(defn- read-json [xhrio]
  (let [response (.getResponse xhrio)]
    (if (string/blank? response)
      nil
      (js->clj (.parse js/JSON response) :keywordize-keys true))))

(defn- get-size [xhrio]
  (int (peek (str/split (.getResponseHeader xhrio "Content-Range") "/"))))

(defn- group-response [response by]
  (->>
    response
    (group-by by)
    (map (fn [[k v]] [k (peek v)]))
    (into (sorted-map-by (fn [k1 k2] (> k1 k2))))))


(defn- format-response [response-format xhrio]
  (match response-format
         :json (read-json xhrio)
         :json-with-size [(get-size xhrio) (read-json xhrio)]
         [:grouped-json-with-size by] [(get-size xhrio) (group-response (read-json xhrio) by)]
         :else (read-json xhrio)))

(defn- basic-request [{:keys [path token params method page api-method on-success-args response-format prefer]}]
  {:uri        (str "http://localhost:3000/" path)
   :timeout    60000
   :format     (ajax/json-request-format)
   :on-success (vec (concat [:on-api-call-done api-method] on-success-args))
   :on-failure [:on-failure]
   :params     params
   :method     method
   :response-format
               {:read        (partial format-response response-format)
                :description "raw"}
   :headers    (cond-> {:Accept "application/json"}
                       token (assoc :Authorization (str "Bearer " token))
                       prefer (assoc :Prefer prefer)
                       page (assoc :Range (str (* 20 (- page 1)) "-" (* 20 page))))})


(defmulti create-request :api-method)

(defmethod create-request :auth/signin [request [creds]]
  (basic-request (assoc request
                   :params creds
                   :path "rpc/login"
                   :on-success-args [(:email creds)]
                   :method :POST)))

(defmethod create-request :programs/list [request [page filter]]
  (let [params {:order  "id.desc"
                :select "*,scope{scope-program{*}}"}]
    (basic-request (assoc request
                     :path "programs"
                     :method :GET
                     :page page
                     :params (if (str/blank? filter)
                               params
                               (assoc params :fts (str "@@." filter ":*")))
                     :response-format [:grouped-json-with-size :id]))))
;
(defmethod create-request :programs/details [request [program-id]]
  (basic-request (assoc request
                   :path "programs"
                   :method :GET
                   :prefer "plurality=singular"
                   :on-success-args [program-id]
                   :params {:id                      (str "eq." program-id)
                            :select                  "*,scope{scope-program{*}},tasks{*},execution-results{status,args,id,task{*}}"
                            :tasks.status            "neq.completed"
                            :tasks.order             "id.desc"
                            :execution-results.order "id.desc"
                            :execution-results.limit 20})))

(defmethod create-request :programs/remove-from-scope [request [current-program-id removing-program-id]]
  ;todo ugly. fix this
  (basic-request (assoc request
                   :path (str "scope?" "program=eq." current-program-id "&" "scope-program=eq." removing-program-id)
                   :method :DELETE
                   :on-success-args [current-program-id removing-program-id])))
;:params {:program (str "eq." current-program-id) :scope-program (str "eq." removing-program-id)}}))

(defmethod create-request :programs/add-to-scope [request [current-program-id adding-program]]
  (basic-request (assoc request
                   :path "scope"
                   :method :POST
                   :response-format :raw
                   :params {:program current-program-id :scope-program (:id adding-program)}
                   :on-success-args [current-program-id adding-program])))

(defmethod create-request :programs/add [request [name-and-desc]]
  (basic-request (assoc request
                   :path "programs"
                   :method :POST
                   :prefer "return=representation"
                   :response-format :json
                   :params (assoc name-and-desc :code ""))))

(defmethod create-request :programs/delete [request [program-id]]
  (basic-request (assoc request
                   :path (str "programs?id=eq." program-id)
                   :method :DELETE
                   :on-success-args [program-id])))


(defmethod create-request :programs/update [request [program]]
  (basic-request (assoc request
                   :path (str "programs?" "id=eq." (:id program))
                   :method :PATCH
                   :response-format :raw
                   :params program
                   :on-success-args [program])))

(defmethod create-request :programs/run [request [program-id]]
  (basic-request (assoc request
                   :path "tasks"
                   :method :POST
                   :response-format :json
                   :prefer "return=representation"
                   :params {:status "free" :program program-id})))


(defmethod create-request :tasks/list [request [page]]
  (basic-request (assoc request
                   :path "tasks"
                   :method :GET
                   :page page
                   :params {:order  "id.desc"
                            :select "*,program{id, name}"
                            :status "neq.completed"}
                   :response-format [:grouped-json-with-size :id])))


(defmethod create-request :execution-results/content [request [execution-results-id program-id]]
  (basic-request (assoc request
                   :path "execution-results"
                   :method :GET
                   :on-success-args [program-id]
                   :prefer "plurality=singular"
                   :params {:id     (str "eq." execution-results-id)
                            :select "id,content"})))


(defmulti on-response identity)

(defmethod on-response :auth/signin [_ [email token] db]
  (let [creds (assoc token :author email)]
    {:db            (assoc db :creds creds)
     :->local-store ["creds" creds]}))

(defmethod on-response :programs/list [_ [programs] db]
  (assoc db :programs
            (->> programs
                 (transform [s/LAST s/MAP-VALS :scope s/ALL] :scope-program)
                 (transform [s/LAST s/MAP-VALS] #(u/deep-merge (get-in db [:programs 1 (:id %)]) %)))))


(defmethod on-response :programs/details [_ [id program] db]
  (update-in db [:programs 1 id] u/deep-merge
             (->> program
                  (transform [:scope s/ALL] :scope-program))))


(defmethod on-response :programs/remove-from-scope [_ [current-program-id removing-program-id] db]
  (update-in db [:programs 1 current-program-id :scope] (fn [scope]
                                                          (filter #(not= (:id %) removing-program-id) scope))))

(defmethod on-response :programs/add-to-scope [_ [current-program-id adding-program] db]
  (update-in db [:programs 1 current-program-id :scope] conj adding-program))

(defmethod on-response :programs/add [_ [program] db]
  {:db  (update-in db [:programs 1] assoc (:id program) program)
   :nav (routes/program-details (:id program))})

(defmethod on-response :programs/delete [_ [program-id] db]
  (update-in db [:programs 1] dissoc program-id))

(defmethod on-response :programs/update [_ [program] db]
  (update-in db [:programs 1 (:id program)] merge program))

(defmethod on-response :programs/run [_ [task] db]
  (-> db
      (update-in [:programs 1 (:program task) :tasks] conj task)))

(defmethod on-response :tasks/list [_ [tasks] db]
  (assoc db :tasks tasks))

(defmethod on-response :execution-results/content [_ [program-id result] db]
  {:db    db
   :unzip {:hex-string (:content result)
           :on-success [:unzip program-id (:id result)]
           :on-failure [:on-failure]}})

(reg-event-db
  :set-pending
  default-interceptors
  (fn [db _]
    (if (nil? (:pending? db))
      (assoc db :pending? true)
      db)))

(reg-event-fx
  :api-call
  default-interceptors
  (fn [{:keys [db]} [method & params]]
    {:dispatch-later [{:ms 200 :dispatch [:set-pending]}]
     :db             (assoc db :pending? nil)
     :http-xhrio     (create-request {:api-method method :token (get-in db [:creds :token])} params)}))

(reg-event-fx
  :api-call-async
  default-interceptors
  (fn [{:keys [db]} [method & params]]
    {:db         (assoc db :pending? nil)
     :http-xhrio (create-request {:api-method method :token (get-in db [:creds :token])} params)}))

(reg-event-fx
  :on-api-call-done
  default-interceptors
  (fn [{:keys [db]} [method & params]]
    (let [resp (on-response method params db)]
      (if (:db resp)
        (update-in resp [:db] assoc :pending? false)
        {:db (assoc resp :pending? false)}))))


(reg-event-fx
  :on-failure
  default-interceptors
  (fn [{:keys [db]} [resp]]
    {:db         (assoc db :pending? false :error-message resp)
     :open-modal "error-modal"}))

