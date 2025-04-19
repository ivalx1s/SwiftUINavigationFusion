# NavigationFusion

**NavigationFusion** — это SwiftUI-совместимая навигационная обертка над `UINavigationController` с фокусом на императивный стиль и поддержку глубоких модальных стеков. Проект показывает, как можно писать читаемую, контролируемую навигацию в SwiftUI-приложениях.

---

## 🚀 Возможности

- ✅ Навигация через `Navigator`: `push`, `pop`, `sheet`, `cover`, `dismiss`
- ✅ Работа с модальными окнами: поддержка `.sheet`, `.fullScreenCover`
- ✅ Возможность `push` внутри `sheet` или `cover` (глубокая модальная навигация)
- ✅ Поддержка `pop(levels:)`, `popToRoot()`
- ✅ Пример с `Coordinator`-архитектурой
- ✅ Легкое внедрение в любое SwiftUI-приложение

---

## 📦 Структура проекта

| Модуль | Назначение |
|--------|------------|
| `FusionCore` | Навигационное ядро: `Navigator`, `Navigation` — обертки над UIKit |
| `NavigationFusion` | Пример использования: два таба — один с ручной навигацией, другой с координатором |

---

## 🧑‍💻 Как использовать

### 1. Внедрение Navigation wrapper-а:
```swift
Navigation { navigator in
    MyRootView(navigator: navigator)
}
```

### 2. Навигация из любого места:
```swift
navigator.push(DetailView(navigator: navigator))

navigator.presentSheet { nav in
    MySheet(navigator: nav)
}

navigator.presentFullScreen { nav in
    MyCover(navigator: nav)
}
```

### 3. Переход назад:
```swift
navigator.pop()               // Один уровень
navigator.pop(levels: 2)      // Несколько уровней
navigator.popToRoot()         // Назад к корню
```

### 4. Закрытие модалки:
```swift
navigator.dismiss()
```

---

## 🧠 Зачем использовать

> SwiftUI не даёт прямого доступа к стеку `NavigationController`. NavigationFusion решает это.

- Делает навигацию **явной и императивной**
- Упрощает **тестирование и отладку** навигационных флоу
- Идеально ложится в **Coordinator + ViewModel** архитектуру
- Модально вложенные экраны больше не проблема

---

## 🖼 Пример UI (два таба)

1. **Demo Tab** — прямое использование `Navigator`:
   - Push-переходы
   - Sheet и Cover модалки
   - Навигация внутри модалок

2. **Coordinator Tab** — та же логика, но через `ViewModel + Coordinator`:
   - Всё управление — через ViewModel
   - View чистая, только UI и бинды

---

## 🛠 Пример Coordinator-а

```swift
final class ExampleCoordinator: ObservableObject {
    let navigator: Navigator
    init(navigator: Navigator) { self.navigator = navigator }

    func pushDetail() {
        navigator.push(DetailView(navigator: navigator))
    }

    func showSheet() {
        navigator.presentSheet { nav in
            SheetContent(navigator: nav)
        }
    }

    func pop() {
        navigator.pop()
    }
}
```

---

## 📋 TODO / Идеи

- [ ] Вынести `FusionCore` в отдельный Swift Package
- [ ] Добавить примеры анимаций и кастомных переходов
- [ ] Поддержка deeplink-навигации
- [ ] Навигация по enum-навигационной схеме (Router-style)

---

## 👩‍💻 Автор

Code by братюня, духом John Sundell, телом Swift 6.0 😎

---

## 📄 License

MIT