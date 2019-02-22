window.edit_post = (button) ->
  pass = button.previousElementSibling
  r = new XMLHttpRequest()
  r.onreadystatechange = ->
    if r.readyState != 4 or r.status != 200
      return
    if r.responseText == 'wrngpss'
      document.querySelector("#post_#{pass.getAttribute('name')} #edit #err").innerHTML = 'Неправильный пароль'
      return
    document.querySelector("#post_#{pass.getAttribute('name')} #edit").innerHTML = r.responseText
  r.open 'POST', "/guest/edit/#{pass.getAttribute('name')}", true
  r.setRequestHeader("Content-type","application/x-www-form-urlencoded");
  r.send("pass=#{pass.value}");

window.change_post = (button) ->
  post_id = button.getAttribute('name')
  message = document.querySelector('.cur_mes textarea')
  r = new XMLHttpRequest()
  r.onreadystatechange = ->
    if r.readyState!= 4 or r.status != 200
      return
    document.querySelector("#post_#{post_id} #edit").innerHTML = r.responseText
  r.open 'POST', "/guest/edit/#{post_id}"
  r.setRequestHeader("Content-type","application/x-www-form-urlencoded");
  r.send("mess=#{message.value}")
window.change_cur_pos = (post) ->
  document.querySelector('.cur_pos').setAttribute('class', 'not_cur_pos')
  document.querySelector('.cur_mes').setAttribute('style', 'display: none')
  document.querySelector('.cur_mes').setAttribute('class', 'not_cur_pos')
  document.querySelector("#btn_#{post}").setAttribute('class', 'cur_pos')
  document.querySelector("#mes_#{post}").removeAttribute('style')
  document.querySelector("#mes_#{post}").setAttribute('class', 'cur_mes')
