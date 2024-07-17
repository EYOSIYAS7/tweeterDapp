// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

interface Iprofile {

        struct UserProfile {
        string displayName;
        string bio;
    }
    function  getProfile(address _user) external view returns (UserProfile memory);
    
}
contract Tweeter {
    mapping (address => Tweets[]) public tweet;
    uint16 MaxTweetLength = 500;
    struct Tweets { 
        uint256 id;
        address author;
        string tweetContent;
        uint256 timestamp;
        uint256 likes;
    }

    Iprofile profileContract;
    
    address public owner; 
    constructor (address _ProfileContractAddress) {
        owner = msg.sender;
        // initalizing the contract
        profileContract = Iprofile(_ProfileContractAddress);
    }

    modifier ownerOnly () {
        require(msg.sender == owner, "this function can only be called by the owner");
        _;
    }

    modifier registerOnly () {
        uint  userNamelength = bytes(profileContract.getProfile(msg.sender).displayName).length;
        require(userNamelength > 0 , "the user must be registered");
        _;
    }

    event TweetCreated (address author, uint256 id, uint256 timestamp, string content);

    event TweetLiked (address tweetAuthor, address liker, uint256 likeCount, uint256 tweetId);

    event TweetUnliked( address tweetAuthor , address unliker, uint256 likeCount, uint256 tweetId);

    function createTweet (string memory _tweet) public registerOnly{

        require(bytes(_tweet).length <= MaxTweetLength, "The tweet is too long");

        Tweets memory newTweet =Tweets({
                id: tweet[msg.sender].length,
                author: msg.sender,
                tweetContent: _tweet,
                timestamp : block.timestamp,
                likes: 0

        });
        // array of tweets of individual user
        tweet[msg.sender].push(newTweet);
         
        emit TweetCreated(msg.sender, tweet[msg.sender].length, block.timestamp, _tweet);
    }

    function getTweet (address user, uint256 _index) public view returns (Tweets memory){
        return tweet[user][_index];
    }

    function getAllTweets ( address user) public view returns ( Tweets[] memory){
        return tweet[user];
    }

    function changeMaxTweetLength ( uint16 _tweetLength) public ownerOnly {
        MaxTweetLength = _tweetLength;
    }

    function likeTweet (address _author, uint256 _id) external registerOnly{
        require(tweet[_author][_id].id == _id, "the tweet doesn't exists");
        tweet[_author][_id].likes++;

        emit TweetLiked(_author, msg.sender, tweet[_author][_id].likes, tweet[_author][_id].id);
    }

    function getTotalLikes( address author) external view returns (uint) {

      uint totalLikes;
      for (uint i= 0; i <= tweet[author].length; i++) 
      {
         totalLikes += tweet[author][i].likes;
      }
      return totalLikes;
    }
    
    function unlikeTweet ( address _author , uint256 _id) external registerOnly {
        require(tweet[_author][_id].id == _id, "the tweet doesn't exists");
        require(tweet[_author][_id].likes >= _id, "the tweet doen't have likes");
        tweet[_author][_id].likes--;

        emit TweetUnliked(_author, msg.sender,  tweet[_author][_id].likes, _id);
    }
} 