document.addEventListener("DOMContentLoaded", () => {
  const registerForm = document.getElementById("registerForm")
  const username = document.getElementById("username")
  const password = document.getElementById("password")
  const confirmPassword = document.getElementById("confirmPassword")
  const profileImage = document.getElementById("profileImage")
  const previewImg = document.getElementById("previewImg")
  const checkUsernameBtn = document.getElementById("checkUsernameBtn")

  let isUsernameChecked = false
  let isUsernameAvailable = false

  // 이미지 미리보기
  profileImage.addEventListener("change", (e) => {
    const file = e.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        previewImg.src = e.target.result
      }
      reader.readAsDataURL(file)
    } else {
      previewImg.src = "image/default-profile.png"
    }
  })

  // 아이디 입력 시 중복확인 상태 초기화
  username.addEventListener("input", () => {
    isUsernameChecked = false
    isUsernameAvailable = false
    document.getElementById("usernameError").textContent = ""
    document.getElementById("usernameError").style.color = "red"
    checkUsernameBtn.disabled = false
    checkUsernameBtn.textContent = "중복확인"
    checkUsernameBtn.className = "check-btn"
  })

  // 아이디 중복확인 버튼 클릭
  checkUsernameBtn.addEventListener("click", () => {
    const usernameValue = username.value.trim()

    if (!usernameValue) {
      document.getElementById("usernameError").textContent = "아이디를 입력해주세요."
      return
    }

    // 아이디 형식 검사
    const usernameRegex = /^[a-zA-Z0-9]{4,20}$/
    if (!usernameRegex.test(usernameValue)) {
      document.getElementById("usernameError").textContent = "아이디는 영문, 숫자 조합 4-20자로 입력해주세요."
      return
    }

    // AJAX 요청
    checkUsernameBtn.disabled = true
    checkUsernameBtn.textContent = "확인중..."

    // 절대 경로로 수정
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 2))
    const requestUrl = contextPath + "/CheckUsernameServlet"

    console.log("요청 URL:", requestUrl) // 디버그용

    fetch(requestUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "username=" + encodeURIComponent(usernameValue),
    })
      .then((response) => {
        console.log("응답 상태:", response.status) // 디버그용
        if (!response.ok) {
          throw new Error("HTTP " + response.status)
        }
        return response.json()
      })
      .then((data) => {
        console.log("응답 데이터:", data) // 디버그용
        isUsernameChecked = true
        isUsernameAvailable = data.available

        const errorElement = document.getElementById("usernameError")
        errorElement.textContent = data.message

        if (data.available) {
          errorElement.style.color = "green"
          checkUsernameBtn.textContent = "확인완료"
          checkUsernameBtn.className = "check-btn success"
        } else {
          errorElement.style.color = "red"
          checkUsernameBtn.textContent = "중복확인"
          checkUsernameBtn.className = "check-btn"
        }

        checkUsernameBtn.disabled = false
      })
      .catch((error) => {
        console.error("Error:", error)
        document.getElementById("usernameError").textContent = "서버 연결 오류: " + error.message
        document.getElementById("usernameError").style.color = "red"
        checkUsernameBtn.disabled = false
        checkUsernameBtn.textContent = "중복확인"
      })
  })

  // 폼 제출 시 유효성 검사
  registerForm.addEventListener("submit", (e) => {
    let isValid = true

    // 아이디 중복확인 여부 체크
    if (!isUsernameChecked || !isUsernameAvailable) {
      document.getElementById("usernameError").textContent = "아이디 중복확인을 해주세요."
      document.getElementById("usernameError").style.color = "red"
      isValid = false
    }

    // 아이디 검사 (영문, 숫자 조합 4-20자)
    const usernameRegex = /^[a-zA-Z0-9]{4,20}$/
    if (!usernameRegex.test(username.value)) {
      if (isValid) {
        // 중복확인 오류가 없을 때만 표시
        document.getElementById("usernameError").textContent = "아이디는 영문, 숫자 조합 4-20자로 입력해주세요."
        document.getElementById("usernameError").style.color = "red"
      }
      isValid = false
    }

    // 비밀번호 검사 (8자 이상, 영문, 숫자, 특수문자 포함)
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/
    if (!passwordRegex.test(password.value)) {
      document.getElementById("passwordError").textContent =
        "비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다."
      isValid = false
    } else {
      document.getElementById("passwordError").textContent = ""
    }

    // 비밀번호 확인
    if (password.value !== confirmPassword.value) {
      document.getElementById("confirmPasswordError").textContent = "비밀번호가 일치하지 않습니다."
      isValid = false
    } else {
      document.getElementById("confirmPasswordError").textContent = ""
    }

    if (!isValid) {
      e.preventDefault()
    }
  })
})
