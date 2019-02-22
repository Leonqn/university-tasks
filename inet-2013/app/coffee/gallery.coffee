window.show = (e) ->
  e = e || window.event
  target = (e.srcElement || e.target).parentNode;
  if target.nodeName == 'A'
    img = get_img();
    set_img(img, target.getAttribute('title'))
    img.parentNode.setAttribute('style', "display: flex; display: -ms-flexbox;")
#    preload();

#preload = ->
#  for i in window.imgs
#    document.createElement('img').src = i.getAttribute('href')

get_img = ->
  document.getElementById('overlay').getElementsByTagName('img')[0]

set_img = (img, id)->
  window.imgs = window.imgs || document.getElementById('thumbs').getElementsByTagName('a')
  window.history.pushState({id: id}, null, "/gallery/#{window.imgs[id].getAttribute('title')}")
  img.setAttribute('id', id)
  img.src = window.imgs[id].getAttribute('href')
  document.getElementById("loading").style.display = 'inline' if !img.complete
  img.alt = window.imgs[id].getAttribute('title')
  preload()

preload = ->
  [_, prev_id] = get_prev_image()
  [_, next_id] = get_next_image()
  document.createElement('img').src = window.imgs[prev_id].getAttribute('href')
  document.createElement('img').src = window.imgs[next_id].getAttribute('href')

get_prev_image = ->
  img = get_img()
  id = parseInt img.getAttribute('id');
  id = if id <= 0 then window.imgs.length - 1 else id - 1
  [img, id]
show_prev_image = ->
  [img, id] = get_prev_image()
  set_img(img, id)

get_next_image = ->
  img = get_img()
  id = parseInt img.getAttribute('id');
  id = if id >= window.imgs.length - 1 then 0 else id + 1
  [img, id]

show_next_image = ->
  [img, id] = get_next_image()
  set_img(img, id)

close_image = ->
  img = get_img()
  img.parentNode.style.display = 'none'
  img.src = ''
  window.history.pushState({id: null}, null, "/gallery")

window.next = (e) ->
  window.imgs = window.imgs || document.getElementById('thumbs').getElementsByTagName('a')
  e = e || window.event
  target = e.target || e.srcElement
  id = target.getAttribute('id')
  if id is 'prev' or id is 'prev_img'
    return show_prev_image()
  if id is 'close' or id is 'close_img'
    return close_image()
  if id is 'do_start'
    return do_start()
  show_next_image()

document.onkeyup = (e) ->
  overlay = document.getElementById('overlay')
  if overlay.style.display != 'none'
    switch e.keyCode
      when 37 then show_prev_image()
      when 39 then show_next_image()
      when 27 then close_image()


window.onpopstate = (e) ->
  if e.state != null
    img = get_img()
    if e.state.id == null
        img.parentNode.style.display = 'none'
        img.src = ''
        return
    img.parentNode.setAttribute('style', "display: flex; display: -ms-flexbox;") if img.parentNode.style.display == 'none'
    id = e.state.id
    window.imgs = window.imgs || document.getElementById('thumbs').getElementsByTagName('a')
    img.setAttribute('id', id)
    img.src = window.imgs[id].getAttribute('href')
    img.alt = window.imgs[id].getAttribute('title')

window.opacity_buttons_over = (ctx) ->
  ctx.firstElementChild.style.opacity = 1
window.opacity_buttons_out = (ctx) ->
  ctx.firstElementChild.style.opacity = 0.4

set_cookie =(img) ->
  document.cookie = "id=#{img.getAttribute('id')}"

window.onload = ->
  img = get_img()
  cook = get_cookie('id')
  if cook != undefined and img.getAttribute('id') == 'img'
    img.parentNode.setAttribute('style', "display: flex; display: -ms-flexbox;")
    set_img(img, cook)
    preload()

get_cookie = (name) ->
  matches = document.cookie.match(new RegExp(
    "(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + "=([^;]*)"))
  if matches then decodeURIComponent(matches[1]) else undefined
window.do_start = ->
  set_cookie get_img()
