# prac_flo
프로그래머스 과제 flo연습



## 개발하면서고민

> 네트워크 레이어 구성

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








> 현재 재생중인 부분 가사 하이라이팅되는 애니메이션구현





