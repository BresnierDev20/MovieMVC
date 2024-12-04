//
//  NetworkService.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import Foundation
import Alamofire

protocol IEndpoint {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameter: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

class NetworkService {
    // Singleton compartido
    static let shared = NetworkService()

    // Sesión reutilizable con configuración predeterminada
    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()

    private let baseUrl = "https://api.themoviedb.org/3/movie/"
    private var activeRequest: DataRequest?

    // Método privado para crear DataRequest
    @discardableResult
    private func makeRequest(
        url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders? = nil
    ) -> DataRequest {
        return session.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }

    // Función pública para hacer requests
    func request<T: IEndpoint>(endpoint: T, completion: @escaping (Result<Data?, Error>) -> Void) {
        let url = baseUrl + endpoint.path
        
        activeRequest = makeRequest(
            url: url,
            method: endpoint.method,
            parameters: endpoint.parameter,
            encoding: endpoint.encoding,
            headers: nil
        )

        activeRequest?.responseData { response in
            self.handleResponse(response, completion: completion)
        }
    }

    // Manejo centralizado de respuestas
    private func handleResponse(_ response: AFDataResponse<Data>, completion: (Result<Data?, Error>) -> Void) {
        switch response.result {
        case .success(let data):
            completion(.success(data))
        case .failure(let error):
            completion(.failure(error))
        }
    }

    // Actualización de token desde headers
//    func refreshToken(from headers: [AnyHashable: Any]?) {
////        guard let token = headers?["Authorization"] as? String else { return }
//////        LHSettings.current.jwtToken = token
//    }

    // Cancelación de la request activa
    func cancelRequest(completion: (() -> Void)? = nil) {
        activeRequest?.cancel()
        completion?()
    }

    // Cancelar todas las requests activas
    func cancelAllRequests(completion: (() -> Void)? = nil) {
        session.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            (dataTasks + uploadTasks + downloadTasks).forEach { $0.cancel() }
            completion?()
        }
    }
}

// Encoding personalizado para body en formato String
struct BodyStringEncoding: ParameterEncoding {
    private let body: String

    init(body: String) { self.body = body }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest else { throw Errors.emptyURLRequest }
        guard let data = body.data(using: .utf8) else { throw Errors.encodingProblem }
        urlRequest.httpBody = data
        return urlRequest
    }

    enum Errors: Error {
        case emptyURLRequest
        case encodingProblem
    }
}

extension BodyStringEncoding.Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyURLRequest:
            return "Empty URL request"
        case .encodingProblem:
            return "Encoding problem"
        }
    }
}

