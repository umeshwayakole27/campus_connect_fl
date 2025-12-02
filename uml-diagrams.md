# Campus Connect - UML Diagrams

Simple and clean UML diagrams for the Campus Connect mobile application.

---

## 1. Class Diagram

**Purpose:** Core classes and their relationships.

```plantuml
@startuml
title Class Diagram - Campus Connect

' Models
class AppUser {
  + id : String
  + email : String
  + name : String
  + role : String
  + isStudent() : bool
  + isFaculty() : bool
}

class Event {
  + id : String
  + title : String
  + location : String
  + time : DateTime
  + createdBy : String
}

class Faculty {
  + userId : String
  + department : String
  + officeLocation : String
  + phone : String
}

class CampusLocation {
  + name : String
  + lat : double
  + lng : double
}

' Repositories
class AuthRepository {
  + signIn()
  + signUp()
  + signOut()
}

class EventRepository {
  + getAllEvents()
  + createEvent()
  + updateEvent()
}

' Providers
class AuthProvider {
  + currentUser : AppUser
  + isAuthenticated : bool
  + signIn()
  + signOut()
}

class EventProvider {
  + events : List<Event>
  + loadEvents()
  + createEvent()
}

' Services
class SupabaseService {
  + client
  + initialize()
}

' Relationships
AppUser "1" -- "0..1" Faculty
Event "*" --> "1" AppUser
Event "*" --> "0..1" CampusLocation

AuthProvider --> AuthRepository
EventProvider --> EventRepository

AuthRepository ..> SupabaseService
EventRepository ..> SupabaseService

@enduml
```

---

## 2. Use Case Diagram

**Purpose:** What users can do in the system.

```plantuml
@startuml
title Use Case Diagram - Campus Connect

left to right direction

actor Student as S
actor Faculty as F

package "Campus Connect System" {
  
  usecase "Login" as UC1
  usecase "View Events" as UC2
  usecase "Browse Faculty" as UC3
  usecase "Campus Map" as UC4
  usecase "Search" as UC5
  usecase "Receive Notifications" as UC6
  usecase "Create Event" as UC7
  usecase "Manage Events" as UC8
  usecase "Send Notifications" as UC9
  usecase "View Locations" as UC10
  usecase "Get Directions" as UC11
  
}

' Student use cases
S --> UC1
S --> UC2
S --> UC3
S --> UC4
S --> UC5
S --> UC6
S --> UC10
S --> UC11

' Faculty use cases
F --> UC1
F --> UC2
F --> UC3
F --> UC4
F --> UC5
F --> UC6
F --> UC7
F --> UC8
F --> UC9
F --> UC10
F --> UC11

' Include relationships
UC7 ..> UC9 : <<include>>
UC8 ..> UC9 : <<include>>

' Extend relationships
UC11 ..> UC10 : <<extend>>
UC11 ..> UC4 : <<extend>>

@enduml
```

**User Roles:**
- **Student**: Login, View Events, Browse Faculty, Campus Map, Search, Receive Notifications, View Locations, Get Directions
- **Faculty**: All student features + Create Event, Manage Events, Send Notifications

**Key Interactions:**
- **Get Directions**: Users can click on any location (from map, events, faculty offices) to get turn-by-turn directions
- **Send Notifications**: Automatically triggered when faculty creates or manages events

---

## 3. ER Diagram

**Purpose:** Database structure and relationships.

```plantuml
@startuml
title ER Diagram - Campus Connect Database

entity "users" as users {
  * id : UUID
  --
  * email : TEXT
  * name : TEXT
  * role : TEXT
  profile_pic : TEXT
}

entity "faculty" as faculty {
  * id : UUID
  --
  * user_id : UUID <<FK>>
  * department : TEXT
  office_location : TEXT
  phone : TEXT
}

entity "events" as events {
  * id : UUID
  --
  * title : TEXT
  * time : TIMESTAMP
  location : TEXT
  location_id : UUID <<FK>>
  created_by : UUID <<FK>>
}

entity "campus_locations" as locations {
  * id : UUID
  --
  * name : TEXT
  * lat : DOUBLE
  * lng : DOUBLE
}

entity "notifications" as notifications {
  * id : UUID
  --
  user_id : UUID <<FK>>
  event_id : UUID <<FK>>
  * message : TEXT
  read : BOOLEAN
}

users ||--o| faculty
users ||--o{ events
users ||--o{ notifications
locations ||--o{ events
events ||--o{ notifications

@enduml
```

**Tables:**
- **users**: All user accounts
- **faculty**: Faculty profile details
- **events**: Campus events
- **campus_locations**: Buildings with GPS coordinates
- **notifications**: Push notifications

---

## 4. Sequence Diagram - Login Flow

**Purpose:** User authentication process.

```plantuml
@startuml
title Login Flow

actor User
participant UI
participant AuthProvider
participant AuthRepository
participant Supabase
database Database

User -> UI : Enter credentials
UI -> AuthProvider : signIn()
AuthProvider -> AuthRepository : signIn()
AuthRepository -> Supabase : authenticate
Supabase -> Database : verify credentials
Database --> Supabase : user data
Supabase --> AuthRepository : session
AuthRepository --> AuthProvider : user profile
AuthProvider --> UI : success
UI --> User : Navigate to Home

@enduml
```

---

## 5. Sequence Diagram - Create Event Flow

**Purpose:** Faculty creates a new event.

```plantuml
@startuml
title Create Event Flow

actor Faculty
participant UI
participant EventProvider
participant EventRepository
participant Supabase
participant FCM

Faculty -> UI : Fill event details
UI -> EventProvider : createEvent()
EventProvider -> EventRepository : createEvent()
EventRepository -> Supabase : insert event
Supabase --> EventRepository : event created
EventRepository --> EventProvider : success
EventProvider -> FCM : send push notifications
FCM --> EventProvider : notifications sent
EventProvider --> UI : update list
UI --> Faculty : Show success

@enduml
```

---

## 6. Activity Diagram - Search Flow

**Purpose:** Global search workflow.

```plantuml
@startuml
title Global Search Flow

start

:Enter search query;

if (Query >= 2 chars?) then (yes)
  fork
    :Search Events;
  fork again
    :Search Faculty;
  fork again
    :Search Locations;
  end fork
  
  :Combine results;
  
  if (Results found?) then (yes)
    :Display results;
    :User selects item;
    :Navigate to details;
  else (no)
    :Show "No results";
  endif
else (no)
  :Show search history;
endif

stop

@enduml
```

---

## 7. Component Diagram - Architecture

**Purpose:** System architecture overview.

```plantuml
@startuml
title System Architecture

package "UI Layer" {
  [Screens]
}

package "State Management" {
  [Providers]
}

package "Business Logic" {
  [Repositories]
}

package "Services" {
  [Supabase]
  [Firebase FCM]
  [Google Maps]
}

database "PostgreSQL" as DB

[Screens] --> [Providers]
[Providers] --> [Repositories]
[Repositories] --> [Supabase]
[Repositories] --> [Firebase FCM]
[Screens] --> [Google Maps]
[Supabase] --> DB

@enduml
```

**Layers:**
- **UI Layer**: Flutter screens and widgets
- **State Management**: Provider pattern
- **Business Logic**: Repositories for data operations
- **Services**: External integrations (Supabase, Firebase, Google Maps)

---

## Quick Reference

### Key Diagrams

1. **Class Diagram**: Core classes (Models, Repositories, Providers, Services)
2. **Use Case Diagram**: Student and Faculty capabilities
3. **ER Diagram**: Database structure (5 main tables)
4. **Sequence - Login**: Authentication flow
5. **Sequence - Create Event**: Event creation with notifications
6. **Activity - Search**: Global search workflow
7. **Component Diagram**: Layered architecture

### Technology Stack

- **Frontend**: Flutter 3.19+ with Provider
- **Backend**: Supabase (PostgreSQL)
- **Push Notifications**: Firebase Cloud Messaging
- **Maps**: Google Maps API
- **Security**: Row Level Security (RLS)

---

## How to View Diagrams

**Online (Easiest):**
1. Visit: http://www.plantuml.com/plantuml/uml/
2. Copy diagram code (from `@startuml` to `@enduml`)
3. Paste and view

**VS Code:**
1. Install "PlantUML" extension
2. Open this file
3. Press `Alt + D` to preview

---

## Diagram Symbols

- `-->` Uses/Depends on
- `--` Association
- `..>` Creates/Dependency
- `*` Many (e.g., one-to-many)
- `<<FK>>` Foreign Key
- `||--o{` One-to-many relationship

---

## Architecture Patterns

**Clean Architecture**: UI → Providers → Repositories → Services
**Repository Pattern**: Centralized data access
**Provider Pattern**: Reactive state management
**Singleton**: Services (Supabase, Storage)

---

**Last Updated**: 2025-11-30  
**Version**: 2.0  
**Campus Connect Development Team**

