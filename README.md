# prac_flo
프로그래머스 과제 flo연습



## 개발하면서고민

> ### 네트워크 레이어 구성

``` swift

protocol API {
    var url: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: HTTPHeaders? { get }
    var body: Parameters? { get }
}

extension API {
    var baseURL: URL {
        guard let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com") else {
            fatalError("baseURL Error")
        }
        return url
    }
}
```

위의 API프로토콜을 구현하고

``` swift
struct SongAPI: API {
    var url: URL {
        baseURL.appendingPathComponent(path)
    }
    let path: String = "/2020-flo/song.json"
    let method: HTTPMethod = .get
    let header: HTTPHeaders?
    var body: Parameters?
}
```

통신할 API마다 인스턴스를 만들어주고(여기서는 SongAPI)

```swift

final class APIRequest {
    static let shared: APIRequest = APIRequest()
    private init (){ }
  
    private func request<T: Decodable>(api: API, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(api.url,
                   method: api.method,
                   parameters: api.body,
                   encoding: JSONEncoding.default,
                   headers: api.header)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: type) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

extension APIRequest {
    func requestSongInfo(completion: @escaping (Result<Song, Error>) -> Void) {
        let api = SongAPI(header: nil, body: nil)
        request(api: api, type: Song.self) { result in
            switch result {
            case .success(let song):
                completion(.success(song))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
```

통신하는 부분에 해당 인스턴스를 넣어줘서 `generic` 방식으로 통신할 수 있게끔 구현



> ### 플레이어 구현

싱글턴으로 구현해서 한개의 객체만 존재할 수 있도록 구현

**기능**

* 음악의 url을 받아서 다시 음악데이터를 가져오는 로직
  * 데이터를 가져오면 `prepareToPlay` 를 통해서 재생시 딜레이가 없도록함

* 재생
  * 데이터 로드보다 빠르게 재생할 경우 데이터가 nil이므로 제한시간동안 반복해서 데이터를 탐지해서 재생함

* 일시정지



> ### seekbar구현

* seekbar 드래그, 터치시 해당위치 재생
  * progressBar에 panGesture, tapGesture추가
  * progressBar의 가로길이와 마지막으로 터치된 위치의 x좌표의 비율을 재생시간의 비율과 비례하도록 계산해서 재생시간 위치와 progress를 수정함

* 음악재생 끝UI 초기화
  * `AVAudioPlayerDelegate` 의 함수를 통해서 `MusicPlayer`가 재생이 끝나는 이벤트를 감지하고 delegate패턴을 통해 `MusicPlayerViewController` 에 이벤트를 전달해서 플레이어UI를 초기화 하는 작업을 함

* 재생중 UI
  * 종료시 부자연스러운 UI발견(프로그래스바 잠깐 채워짐)
    * 타이머 종료시점 문제해결




> ### 현재 재생중인 부분 가사 하이라이팅구현

* 가사 파싱

``` swift
[00:16:200]we wish you a merry christmas [00:18:300]we wish you a merry christmas [00:21:100]we wish you a merry christmas [00:23:600]and a happy new year
```

위형식의 스트링형태로 데이터를 받아왔고

``` swift
private func SeparationLyrics(_ lyrics: String) -> [(TimeInterval, String)] {
    var timeWithLyrics: [(TimeInterval, String)] = []
    let lyrcis = lyrics.components(separatedBy: .newlines)
    
    var isSaveLyrics = false
    for s in lyrcis {
        var timeString = ""
        var tempLyrics = ""
        for c in s {
            if c == "[" {
                isSaveLyrics = false
            } else if c == "]" {
                isSaveLyrics = true
            } else {
                if isSaveLyrics {
                    tempLyrics.append(c)
                } else {
                    timeString.append(c)
                }
            }
        }
        let time = lyricsTime(timeString)
        timeWithLyrics.append((time, tempLyrics))
    }
    return timeWithLyrics
}
```

개행 단위로 나눈뒤

[]를 기준으로 시간과 가사를 따로 저장한뒤

튜플배열에 저장해서 순서대로 시간과 가사를 파싱함





