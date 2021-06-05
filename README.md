# Flo앱 따라하기
음악앱을 따라 만들어보면서 학습하기위해 시작했습니다.



</br>



## 구현화면

### 재생화면

<div>
  <img src="./재생화면.gif" width="350" height="700">
</div>



### 전체가사화면



</br>



## 개발하면서고민

<kbd>네트워크</kbd>

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



</br>



<kbd>재생화면</kbd>

> ### 플레이어 구현

싱글턴으로 구현해서 한개의 객체만 존재할 수 있도록 구현

**기능**

* 음악의 url을 받아서 다시 음악데이터를 가져오는 로직
  * 데이터를 가져오면 `prepareToPlay` 를 통해서 재생시 딜레이가 없도록함

* 재생
  * 데이터 로드보다 빠르게 재생할 경우 데이터가 nil이므로 제한시간동안 반복해서 데이터를 탐지해서 재생함

* 일시정지



</br>



> ### seekbar구현

* seekbar 드래그, 터치시 해당위치 재생
  * progressBar에 panGesture, tapGesture추가
  * progressBar의 가로길이와 마지막으로 터치된 위치의 x좌표의 비율을 재생시간의 비율과 비례하도록 계산해서 재생시간 위치와 progress를 수정함

* 음악재생 끝UI 초기화
  * `AVAudioPlayerDelegate` 의 함수를 통해서 `MusicPlayer`가 재생이 끝나는 이벤트를 감지하고 delegate패턴을 통해 `MusicPlayerViewController` 에 이벤트를 전달해서 플레이어UI를 초기화 하는 작업을 함

* 재생중 UI
  * 종료시 부자연스러운 UI발견(프로그래스바 잠깐 채워짐)
    * 타이머 종료시점 문제해결



</br>




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

`[` ,`]`를 기준으로 시간과 가사를 따로 저장한뒤

튜플배열에 저장해서 순서대로 시간과 가사를 파싱함



</br>



* 재생위치 가사 노출

`CAScrollLayer`사용

스크롤 이벤트를 받을 필요없이 시간에 의존하여 위치가 변하기때문에 선택

CAScrollLayer를 포함한 class를 생성



</br>



* 가사 Label생성

파싱한 가사정보를 받아서

1줄에 해당하는 가사를 UILabel로 만들고

CAScrollLayer에 더해가는 방식

```swift
func createLyricsLabel(lyricsInfo: [LyricsInfo]) {
    reset()
    
    self.lyricsInfo = lyricsInfo
    var totalY: CGFloat = 0
    for (_, lyrics) in lyricsInfo {
        let label = createLabel(y: totalY, text: lyrics)
        scrollLayer.addSublayer(label.layer)
        lyricsLabels.append(label)
        totalY = label.frame.maxY
    }
}
```



</br>



* 시간에 따른 가사위치를 찾는 함수

``` swift
private func timeForIndex(time: TimeInterval) -> Int {
    for i in lyricsInfo.indices {
        let startTime = lyricsInfo[i].0
        if time < startTime {
            return i-1 < 0 ? 0 : i-1
        }
    }

    return lyricsInfo.count
}
```

가사정보에 들어있는 가사시작시간을 탐색하고
현재 시간보다 검색한 시간이 더 큰경우 바로앞의 인덱스를 반환합니다

인덱스검색시 처음부터 비교해야하는 비효율적인 면이 보여서
전의 index와 비교해서 처리하려고 했는데 임의로 seekbar를 움직여서 이동시킬시 오류가 있어보였습니다.
가사 행의수가 그렇게 많지 않을것 같기 때문에 단순하게 비교하는 로직을 선택했습니다.

timer루프 0.01초마다 index검사
3분기준 180 * 100 ➡️ 18,000번 함수호출
가사 49줄 이라면
18,000 * 49 ➡️ 최대 882,000번 탐색

4분 100줄 = 최대 2,400,000번 탐색



> 개선코드

``` swift
private func timeForIndex(time: TimeInterval) -> Int {
    let mid = lyricsInfo.count / 2
    let midTime = lyricsInfo[mid].0
    
    // 중간보다 시간이 큼 중간부터 탐색
    if time - midTime > 0 {
        for i in mid..<lyricsInfo.count {
            let startTime = lyricsInfo[i].0
            if time < startTime {
                return i-1 < 0 ? 0 : i-1
            }
        }
    } else if time - midTime < 0 {
        for i in 0...mid {
            let startTime = lyricsInfo[i].0
            if time < startTime {
                return i-1 < 0 ? 0 : i-1
            }
        }
    } else {
        return mid
    }
    
    return lyricsInfo.count - 1
}
```

중간시간을 기준으로 전후인지 체크후 전체범위의 반만 반복문 돌리도록 구현

4분 ➡️ 24,000번 함수호출
가사 100줄(중간시간을 기준으로 앞뒤만 비교) ➡️ 24,000 * 50 = 1,200,000번 탐색

</br>



* 해당 가사 위치로 스크롤 및 하이라이팅

``` swift
private func scrollLabel(index: Int) {
    if index == 0 {
        return
    }
    let posY = index * Int(scrollLayer.frame.height/2)
    scrollLayer.scrollMode = .vertically
    scrollLayer.scroll(to: CGPoint(x: 0, y: posY))
}

private func highlightingLabel(index: Int) {
    lyricsLabels[beforeHighlightIndex].textColor = .lightGray
    lyricsLabels[index].textColor = .white
    beforeHighlightIndex = index
}
```

index를 받아와서 해당위치로 스크롤

이전의 가사의 포커스를 없애고 현재가사 포커스



***

<kbd>전체가사화면</kbd>

> ### 스크롤되는 가사

위에서 구현한 클래스를 재사용하려했으나 사용했을경우에 지나간 가사를 볼 수 없는 이슈가 있어서 다른 방법으로 새로구현

클릭이벤트도 받아야하므로 테이블뷰가 적당하다고 생각

``` swift
playerTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { [weak self] timer in
    if !(self?.isProgressDrag ?? false) {
        if Int(MusicPlayer.shared.curTime) > (self?.model?.duration ?? 0) {
            self?.playerTimer?.invalidate()
        }
        let rate =  Float(MusicPlayer.shared.curTime) / Float(model.duration)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.songProgressView.setProgress(rate, animated: true)
        }
        
        let index = MusicPlayer.shared.timeForIndex(time: MusicPlayer.shared.curTime)
        if index == self?.beforeIndex {
            return
        }
        
        let beforeIndexPath = IndexPath(row: self?.beforeIndex ?? 0, section: 0)
        let beforeCell = self?.tableView.cellForRow(at: beforeIndexPath) as? StringCell
        beforeCell?.highlightingLabel(isHightlight: false)
        
        let indexPath = IndexPath(row: index, section: 0)
        let cell = self?.tableView.cellForRow(at: indexPath) as? StringCell
        cell?.highlightingLabel(isHightlight: true)
        
        if (self?.isObservedCurRow ?? false) && !(self?.isScrolled ?? false) {
            self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            self?.layoutIfNeeded()
        }
        self?.beforeIndex = index
    }
}
```

현재 시간에 맞는 row를 찾고 해당 cell을 하이라이팅해줌

스크롤기능이 켜져있다면 따라가도록 구현

인덱스를 클릭하면 해당 가사의 시점으로 플레이어 시간변경

계속스크롤 및 하이라이팅을 동작시키는것은 비효율적이므로 이전의 인덱스와 다를경우에만 이동시키는 방법을 선택함



