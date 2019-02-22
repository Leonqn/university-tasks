help-me-please
==============
**РЕГИСТРАЦИЯ:**
```
POST /hmp/auth/registration
```
 - Headers:

    | Название | Описание |
    |---|---|
    | Content-type | MIME Type. Допустимо только application/json |

 - Body
 
    ```js
    {
    	"id": {id},
    	"firstName": {firstName},
    	"lastName": {lastName},
    	"photo": {photo}
    }
    ```
    | Параметр | Тип | Описание |
    |---|---|---|
    | id | uint | айдишник от вконтактика |
    | firstName | string | имя |
    | lastName | string | фамилия |
    | photo | uri | фоточка |

 - Responses:
 
    | Код | Сообщение | Описание | Тело |
    |---|---|---|---|
    | 201 | Created | все хорошо | идентификатор сессии (guid) |
    | 409 | Conflict | уже есть такой(по айди смотрю) | нет |
    | 415 | Unsupported Media Type | content-type плох или отсутствует | нет |
    | 400 | Какая-то другая ошибка | Bad Request | сообщение об ошибке |

**ПОЛУЧИТЬ ТОЧКИ:**
```
GET /hmp/hp
```

 - Parameters

    | Название | Тип | Описание |
    |---|---|---|
    | side | double | сторона квадрата |
    | lng | double | Долгота |
    | lat | double | широта |
    
 - Headers:

    | Название | Описание |
    |---|---|
    | Authorization | идентификатор сессии |

 - Responses

    | Код | Сообщение | Описание | Тело |
    |---|---|---|---|
    | 200 | OK | точки | точки |
    | 401 | Unauthorized | проблемы с идентификатором сессии | конкретно проблема |    

**ПОСТАВИТЬ ТОЧКУ:**
```
POST /hmp/hp
```
 - Headers:

    | Название | Описание |
    |---|---|
    | Content-type | MIME Type. Допустимо только application/json |
    | Authorization | идентификатор сессии |

 - Body
 
    ```js
    {
    	"Location": {
            "lng": {lng},
            "lat": {lat}
        }
    	"message": {message},
    	"photo": {photo}
    }
    ```
    | Параметр | Тип | Описание |
    |---|---|---|
    | lng | double | долгота |
    | lat | double | широта |
    | message | string | какое-то сообщение |
    | photo | uri | фоточка какая-то |

 - Responses:
 
    | Код | Сообщение | Описание | Тело |
    |---|---|---|---|
    | 201 | Created | все хорошо | нет |
    | 415 | Unsupported Media Type | content-type плох или отсутствует | нет |
    | 401 | Unauthorized | проблемы с идентификатором сессии | конкретно проблема |   
    | 400 | Какая-то другая ошибка | Bad Request | сообщение об ошибке |
