//___FILEHEADER___

import EventKit

class ___FILEBASENAME___: EKVirtualConferenceProvider {

    override func fetchAvailableRoomTypes(completionHandler: @escaping ([EKVirtualConferenceRoomTypeDescriptor]?, Error?) -> Void) {
        let roomType = EKVirtualConferenceRoomTypeDescriptor(title: "My Virtual Conference Room", identifier: "my_virtual_conference_room")
        completionHandler([roomType], nil)
    }
    
    override func fetchVirtualConference(identifier: EKVirtualConferenceRoomTypeIdentifier, completionHandler: @escaping (EKVirtualConferenceDescriptor?, Error?) -> Void) {
        let urlDescriptor = EKVirtualConferenceURLDescriptor(title: nil, url: URL(string: "https://example.com/")!)
        let virtualConferenceDescriptor = EKVirtualConferenceDescriptor(title: "My Virtual Conference", urlDescriptors: [urlDescriptor], conferenceDetails: "Any other notes or details you wish to include about this virtual conference.")
        completionHandler(virtualConferenceDescriptor, nil)
    }
}
