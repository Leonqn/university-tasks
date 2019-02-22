window.vote = (voting) ->
  r = new XMLHttpRequest()
  r.onreadystatechange = ->
    if r.readyState != 4 or r.status != 200
      return
    img = document.querySelector('#vote_result')
    if r.responseText.indexOf('src') != -1 and img
      new_img = r.responseText.match(/src='(.*)'/)[1]
      if img.getAttribute('src') != new_img then img.setAttribute('src', new_img)
    else
      document.getElementById('voting').innerHTML = r.responseText

  checked = get_cheked_button() if voting
  if checked
    r.open 'POST', "/voting", true
    r.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    r.send("vote=#{checked}");
  else
    r.open 'GET', "/voting", true
    r.send null

setInterval(->
  vote(false)
, 10000)
get_cheked_button = ->
  if document.getElementById('ok').checked
    return 'ok'
  if document.getElementById('sr_ok').checked
    return 'sr_ok'
  if document.getElementById('ne_ok').checked
    return 'ne_ok'
  return false