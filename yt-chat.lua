-- To terminate loop: _G.h = nil
LIVE_CHAT_KEY = 'AIzaSyBUPetSUmoZL-OhlxA7wSac5XinrygCqMo'
VIDEO_ID = 'Q4Kuefzhnvo'
CONTINUATION =
	'0ofMyAOyARpYQ2lrcUp3b1lWVU5MWkdsRmFHSmhOMlZCWkVaWFEzSTBaVnBNUkZSUkVndFJORXQxWldaNmFHNTJieG9UNnFqZHVRRU5DZ3RSTkV0MVpXWjZhRzUyYnlBTSiwk7Ks2__zAjAAQAJKJQgAGAAgAEoCCAFQyIqd6dr_8wJYA3gAogEAqgECEACwAQG4AQFQoqvcrNv_8wJY_eq7ltv_8wKCAQIIBIgBAKABj8Xattv_8wI%3D'
MSG_FUNCTION = _G.msg
CONTINUE = false

if _G.h then
	_G.h = nil
	wait(2)
end

url =
	'https://www.youtube.com/youtubei/v1/live_chat/get_live_chat?alt=json&key=' ..
		LIVE_CHAT_KEY
_G.h = {
	['content-type'] = 'application/json',
	['If-Match'] = '*',
	['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36',
	['x-youtube-client-name'] = '1',
	['x-youtube-client-version'] = '2.20210128.02.00',
	['Referer'] = 'https://www.youtube.com/live_chat?is_popout=1&v=' .. VIDEO_ID
}
_G.d = CONTINUE and _G.d or {
	context = {
		client = {
			userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)',
			clientName = 'WEB',
			clientVersion = '1.20211101.00.00',
			originalUrl = 'https://www.youtube.com/live_chat?is_popout=1&v=' .. VIDEO_ID,
			mainAppWebInfo = {
				graftUrl = 'https://www.youtube.com/live_chat?is_popout=1&v=' .. VIDEO_ID
			}
		}
	},
	continuation = CONTINUATION
}

local C = 0
while _G.h do
	_G.r = request {
		Url = url,
		Headers = _G.h,
		Method = 'POST',
		Body = game.HttpService:JSONEncode(_G.d)
	}
	_G.b = game.HttpService:JSONDecode(_G.r.Body)
	local c = _G.b.continuationContents.liveChatContinuation.continuations[1]
	_G.d.continuation =
		(c.reloadContinuationData or c.invalidationContinuationData).continuation

	local a = _G.b.continuationContents.liveChatContinuation.actions
	C = C + 1
	if a then
		C = 0
		for i, ac in next, a do
			if ac.addChatItemAction then
				local i = ac.addChatItemAction.item
				if i.liveChatTextMessageRenderer then
					local t = i.liveChatTextMessageRenderer.message.runs[1].text
					if t then MSG_FUNCTION(t) end
				end
			end
		end
	end
	if C > 2 then wait(4.56) end
end
