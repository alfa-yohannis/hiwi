# Hiwi
Hiwi is a Queue Management System


# User Story: Queue Management System

A user can be an owner (admin), teller, and client. In order to use the system, every user has to register in the system.

**Owner**. An Owner can manage (*CRUD: create, read, update, delete*) queues. Each customer can have multiple queues, identified by a prefix and a maximum number. The queue numbering starts with the prefix followed by zero (0) and can be increased as by 1 the queue progresses. The owner can reset the number back to zero and also able to increase the number. 

**Teller**. The owner can assign another user to the teller of a queue by sending an ivitation. The user has to accept the invitation to confirm it. Tellers have the right to increase the numbers of queues assigned to them. 

**Client**. Clients are users that want to line, getting a number, in a queue. They have to register first either through a barcode scan or by entering a queue ID, using a web or mobile app. During registration, participants must provide their email, phone number, and full name or authenticate using **OAuth** as identifiers for tellers to confirm their identities when their turns are called or displayed. After registration, clients receives their queue number and token (can be a QR/bar-code), which is sent to them via the web app, email, and mobile app notifications. The token is used to simplify confirmation.
 
**Queue**. A queue has a name as a human-friendly identifier. It also has a description that explain the context of the queue, such as location, event, owner, purpose, or other relevant information. Is also has two status, active and inactive. When active, the number can be increased. The latter works oppositely. It has a prefix, e.g., C90, XY456, as a que to differentiate it with other queues visually. A queue can have many tellers that can increase its number. A queue also can have many clients that already registered, assigned a number in that queue.

# Requirements

| Number | Code          | Description                                                                 | Status      | Developer | Remarks |
|--------|---------------|-----------------------------------------------------------------------------|-------------|---------------------|---------|
| 1      | USR-REG       | Users must register to use the system.                                     | Pending     |                     |         |
| 2      | OWN-CRUD      | Owner can manage (create, read, update, delete) queues.                    | Pending     |                     |         |
| 3      | OWN-ASSIGN    | Owner can assign tellers to queues via invitations.                        | Pending     |                     |         |
| 4      | OWN-RESET     | Owner can reset queue numbers back to zero.                                | Pending     |                     |         |
| 5      | OWN-INCREMENT | Owner can increment queue numbers.                                         | Pending     |                     |         |
| 6      | TEL-INCREMENT | Teller can increment queue numbers assigned to them.                       | Pending     |                     |         |
| 7      | CLI-REGISTER  | Clients can register for a queue using a barcode scan or queue ID.         | Pending     |                     |         |
| 8      | CLI-OAUTH     | Clients can authenticate via OAuth during registration.                    | Pending     |                     |         |
| 9      | CLI-DATA      | Clients must provide email, phone, and full name during registration.      | Pending     |                     |         |
| 10     | CLI-TOKEN     | Clients receive queue numbers and tokens (QR/barcode) after registration.  | Pending     |                     |         |
| 11     | Q-MANAGE      | Queue must have a name and description.                                    | Pending     |                     |         |
| 12     | Q-STATUS      | Queue must have two statuses: active and inactive.                         | Pending     |                     |         |
| 13     | Q-PREFIX      | Queue numbers must start with a prefix (e.g., C90, XY456).                 | Pending     |                     |         |
| 14     | Q-MULTI-TELL  | A queue can have multiple tellers assigned.                                | Pending     |                     |         |
| 15     | Q-MULTI-CLI   | A queue can have multiple clients registered.                              | Pending     |                     |         |



### States of the Status Column

The **Status** column represents the progress or condition of a requirement. The possible states are:

1. **Pending**: The requirement is identified but not yet started.
2. **In Progress**: Work is currently being done to implement the requirement.
3. **Completed**: The requirement has been fully implemented and verified.
4. **On Hold**: Work on the requirement is paused due to dependencies or other issues.
5. **Rejected**: The requirement has been reviewed but will not be implemented.
6. **Under Review**: The requirement is being evaluated or tested for further action.


# Diagrams
## Usecase Diagram
![usecase diagram](out/doc/usecase.svg)

<!-- ## Activity Diagram
![activity diagram](doc/out/activity/activity.svg)

## Sequence Diagram
![sequence diagram](doc/out/sequence/sequence.svg)

## Class Diagram
![class diagram](doc/out/class/class.svg)

## Entity Diagram 
![entity diagram](doc/out/entity/entity.svg) -->

# Task
Create Queue Management System using Elixir and Phoenix Framework.