# https://stackoverflow.com/questions/2090551/parse-query-string-in-javascript
# generated by js2coffee 2.1.0
window.getQueryVariable = (variable) ->
    query = window.location.search.substring(1)
    vars = query.split('&')
    i = 0
    while i < vars.length
        pair = vars[i].split('=')
        if decodeURIComponent(pair[0]) == variable
            return decodeURIComponent(pair[1])
        i++
    return

allEmotes = []

config = 
    username: getQueryVariable('username')
    emotes: getQueryVariable('emotes') || true
    subemotes: getQueryVariable('subemotes') || false
    bttvemotes: getQueryVariable('bttvemotes') || false

window.emoteParse = (msg) ->
    replaceEmotes msg.split ' '

emoteLoad = ->
    if config.emotes
        fetchEmotes 'https://twitchemotes.com/global.json', parseTwitchEmotes

    if config.subemotes
        fetchEmotes 'https://twitchemotes.com/subscriber.json', parseTwitchSubEmotes

    if config.bttvemotes
        fetchEmotes 'https://api.betterttv.net/2/emotes', parseBTTVEmotes
        fetchEmotes 'https://api.betterttv.net/2/channels/' + config.username, parseBTTVEmotes

fetchEmotes = (url, callback) ->
    fetch(url)
        .then (response) -> return response.json()
        .then (emoteData) ->
            # great error handling
            try
                callback(emoteData)
            catch nothing

parseTwitchEmotes = (emotes) ->
    Object.keys(emotes).forEach (k) -> allEmotes.push code: k, url: emotes[k].url

parseTwitchSubEmotes = (emotes) ->
    Object.keys(emotes).forEach (k) ->
        Object.keys(emotes[k].emotes).forEach (k2) ->
            allEmotes.push code: k2, url: emotes[k].emotes[k2]

parseBTTVEmotes = (data) ->
    data.emotes.forEach (emote) ->
        allEmotes.push code: emote.code, url: parseBTTVURL(data.urlTemplate, emote) 

parseBTTVURL = (tpl, emote) ->
    tpl
        .replace /{{id}}/, emote.id
        .replace /{{image}}/, '1x'

# http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
escapeRegExp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

reducer = (previous, current) ->
    previous.replace new RegExp('^' + escapeRegExp(current.code) + '$', 'g'), '<img src="' + current.url + '">'

replaceEmotes = (words) ->
    return msg if not allEmotes

    replacedWords = words.map (word) -> allEmotes.reduce reducer, word
    replacedWords.join ' '

emoteLoad()