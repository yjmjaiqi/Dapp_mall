// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Supermarket{
    mapping(address => mapping(uint =>Product)) public stores;
    enum productStatus{open,sold,solding,back}
    mapping (address => mapping(uint => User) ) public usermap;
    mapping(address => mapping(uint =>Product[])) public getstores;
    struct User {
        //用户id
         uint id;
        //用户名
         string username;
        //密码
         string password;
        //地址
         address useraddress;
    }
    struct Product{
        //商品id
        uint id;
        //商品类别
        string class;
        //商品名称
        string name;
        //商品描述
        string describe;
        //商品价格
        uint price;
        //商品详图
        string image;
        //商品上架时间
        string starttime;
        //商品上架期限
        string limittime;
        //商品对应用户(地址)
        address user;   
        //商品当前状态
        productStatus status;
     

    }
      
    // 收货 时间
     uint public auctionLimit;
     uint  public productIndex = 0;
     uint  public userid = 0;
     uint[] public keys;
    address[] public buyer;
     receive() external payable{}
     fallback() external payable{}
    //用户注册
     function adduser(
    string  memory  _username,
    string  memory  _password
     ) public {
         userid += 1;
         User storage user = usermap[msg.sender][userid];
          require(msg.sender !=user.useraddress);
         user.id = userid;
         user.username = _username;
         user.password = _password;
         user.useraddress = msg.sender;

     }
       //用户修改
     function upduser(
    address  _user ,
    string  memory  _username,
    string  memory  _password
     ) public {  
         User storage user = usermap[_user][userid];
         require(msg.sender == _user);
         user.id = userid;
         user.username = _username;
         user.password = _password;

     }
      //用户查询
    function getuser(
  address _getuser
    ) public view returns(
          uint _id,
          address _useraddress,
          string memory _username,
          string memory _password){
            User storage user = usermap[_getuser][userid];
            return(
            user.id,
            user.useraddress,
            user.username,
            user.password);
         }
     //添加商品
     function addProduct(
         string memory _class,
         string memory _name,
         string memory _describe,
         uint _price,
         string memory _image,
         string memory _starttime,
         string memory _limittime
 

     )public{
        productIndex += 1;
        Product storage product = stores[msg.sender][productIndex];
        product.id = productIndex;
        product.class = _class;
        product.name = _name;
        product.describe = _describe;
        product.price = _price;
        product.image = _image;
        product.limittime = _limittime;
        product.starttime = _starttime;
          product.user = msg.sender;
        product.status = productStatus.open;
        stores[msg.sender][productIndex] = product;
        getstores[msg.sender][1].push(product);

     }
     //下架商品
     function delProduct(uint _productIndex,address _useraddress)public{
       require(_useraddress == msg.sender,"yonghudizhibuyizhi");
       delete stores[_useraddress][_productIndex];
      
 }
     //查询商品
     function getProduct(address _useraddress,uint _id)public view returns(
       uint,
       string memory,
       string memory,
       string memory,
       uint,
       string memory,
       string memory,
       string memory,
       productStatus,
       address

     ){
        Product storage product = stores[_useraddress][_id];
        return(
          product.id,
          product.class,
          product.name,
          product.describe,
          product.price,
          product.image,
          product.limittime,
          product.starttime,
           product.status,
          product.user         
        );
     }

 //购买 
           // _address卖家, _productid商品id 
     function contribue(uint _productid,address _address) public payable {
        //require(msg.value > 0);
        Product storage product = stores[_address][_productid];
         product.status = productStatus.solding;
         auctionLimit = block.timestamp + 604800;  
       }
       
   //确认收货 _productid商品编号 _address卖家 
   function Iscompelete(uint _productid,uint _num,address payable _address) public payable returns(
       uint _id,
       uint price,
       uint  _buytime,
       address __buyer, 
       address __solder
       ) {
       Product storage product = stores[_address][_productid];
      //  require( productStatus.solding ==product.status ,"erro not equel");
      _address.transfer(product.price *_num * 10**18);
      product.status = productStatus.sold;
      return(
          product.id,
          product.price,
          block.timestamp,
          msg.sender,
          _address);
        
    }
      
     //催促对方收货 _productid商品编号 _address卖家 
     function getmoney(uint _productid1,uint _num,address payable _address1)public{
         uint _id;
         uint price;
         uint _buytime;
          address __buyer;
          address __solder;
          require(block.timestamp >= auctionLimit,"");
          (_id,price,_buytime,__buyer,__solder)=Iscompelete({_productid: _productid1,_num:_num, _address:_address1});
          
     }
         //发起退款 _productid商品编号 _address卖家 
     function returnback(uint _productid,address payable _address) public {
       Product storage product = stores[_address][_productid];
       keys.push(_productid);
        product.status = productStatus.back;
      }
      //同意退款
      function moneyback (uint _productid,uint _num,address payable uder_address,address payable merchant_address)public{
           Product storage product = stores[merchant_address][_productid];
            product.status = productStatus.open;
            uder_address.transfer(product.price * _num * 10 ** 18);
      }
       //  查询功能 
    function getsss(address _key)public view returns(Product[] memory){
        Product[] memory product;
      for (uint i = 0; i<keys.length; i++){
            product  = getstores[_key][1];
      }
      return product;
    }
}