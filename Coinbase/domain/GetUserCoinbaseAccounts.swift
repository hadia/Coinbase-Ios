//
//  GetUserCoinbaseAccounts.swift
//  Coinbase
//
//  Created by hadia on 28/05/2022.
//

import Foundation
import Combine
import Resolver


class GetUserCoinbaseAccounts{
    @Injected private var coinbaseRepository: CoinbaseRepository
    
    func invoke(limit: Int =  300) -> AnyPublisher<CoinbaseUserAccountsResponse, Error> {
        coinbaseRepository.getUserCoinbaseAccounts(limit: limit)
//            .map { (response: CoinBaseUserAccounts) in
//            let list: [CharacterDto] = response.toCharacterDtoList().map { dto in
//                let entity = self.favoriteRepository.getFavorite(id: dto.id)
//                return CharacterDto(created: dto.created, episode: dto.episode, gender: dto.gender, id: dto.id, image: dto.image, location: dto.location, name: dto.name, origin: dto.origin, species: dto.species, status: dto.status, type: dto.type, url: dto.url,isFavorite: entity != nil)
//            }
//            return CharacterListDto(info: response.pageInfo, characters: list)
//        }
            .eraseToAnyPublisher()
    }
}
