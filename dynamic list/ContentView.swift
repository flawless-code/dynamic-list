//
//  ContentView.swift
//  dynamic list
//
//  Created by Kavinkumar Veerakumar on 17/03/21.
//

import SwiftUI


/**
 {
     "time_tag": "2021-03-14T20:00:00",
     "frequency": 2800,
     "flux": 78,
     "reporting_schedule": "Noon",
     "avg_begin_date": "2020-12-15T20:00:00",
     "ninety_day_mean": 77,
     "rec_count": 90
 },
 */
struct Flux: Codable, Hashable {
    var timeTag: Date?
    var frequency: Int?
    var flux: Int?
    var reportingSchedule: String?
    var avgBeginDate: Date?
    var ninetyDayMean: Int?
    var recCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case timeTag = "time_tag"
        case frequency // = "frequency"
        case flux // = "flux"
        case reportingSchedule = "reporting_schedule"
        case avgBeginDate = "avg_begin_date"
        case ninetyDayMean = "ninety_day_mean"
        case recCount = "rec_count"
    }
    
}



struct ContentView: View {
    
    @State private var fluxs = [Flux]()
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List(fluxs, id: \.self) { flux in
                VStack(alignment: .leading, spacing: 5) {
                    if let timeTag = flux.timeTag {
                        Text("Time tag: ")
                            .bold()
                            .foregroundColor(.black) + Text("\(dateFormatter.string(from: timeTag))")
                    }
                    if let frequency = flux.frequency {
                        Text("Frequency: ")
                            .bold()
                            .foregroundColor(.black) + Text("\(frequency)")
                    }
                    if let fluxValue = flux.flux {
                        Text("Flux: ")
                            .bold()
                            .foregroundColor(.black) + Text("\(fluxValue)")
                    }
                    if let reportingSchedule = flux.reportingSchedule {
                        Text("Reporting schedule: ")
                            .bold()
                            .foregroundColor(.black) + Text("\(reportingSchedule)")
                    }
                    if let avgBeginDate = flux.avgBeginDate {
                        Text("Average begin date: ")
                            .bold()
                            .foregroundColor(.black) + Text("\(dateFormatter.string(from: avgBeginDate))")
                    }
                    if let ninetyDayMean = flux.ninetyDayMean {
                        Text("Ninety day mean: ")
                            .bold()
                            .foregroundColor(.black) + Text("\(ninetyDayMean)")
                    }
                    if let recCount = flux.recCount {
                        Text("Rec count: ")
                            .bold()
                            .foregroundColor(.black) + Text("\(recCount)")
                    }
                }
                .foregroundColor(.gray)
                .padding(.vertical, 5)
            }
            .onAppear(perform: {
                fetchFluxs()
            })
            .navigationTitle("Flux")
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel())
        })
    }
    
    var dateFormatter: DateFormatter  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }
    
    func fetchFluxs() {
        guard let url = URL(string: "https://services.swpc.noaa.gov/json/f107_cm_flux.json") else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                if error == nil {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    do {
                        if let data = data {
                            let decodedList = try decoder.decode([Flux].self, from: data)
                            self.fluxs = decodedList
                            
                            print(decodedList)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }.resume()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
