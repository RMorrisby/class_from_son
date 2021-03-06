
import com.fasterxml.jackson.annotation.JsonProperty;

public class GeneratedFromJson {

	private String firstName;
	private String lastName;
	private boolean isAlive;
	private int age;
	private Address address;
	private List<PhoneNumbers> phoneNumbers;
	private List<String> children;
	private String spouse;
	
	public String getFirstName() {
		return firstName;
	}
	
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	
	public String getLastName() {
		return lastName;
	}
	
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	
	public boolean getIsAlive() {
		return isAlive;
	}
	
	public void setIsAlive(boolean isAlive) {
		this.isAlive = isAlive;
	}
	
	public int getAge() {
		return age;
	}
	
	public void setAge(int age) {
		this.age = age;
	}
	
	public Address getAddress() {
		return address;
	}
	
	public void setAddress(Address address) {
		this.address = address;
	}
	
	public List<PhoneNumbers> getPhoneNumbers() {
		return phoneNumbers;
	}
	
	public void setPhoneNumbers(List<PhoneNumbers> phoneNumbers) {
		this.phoneNumbers = phoneNumbers;
	}
	
	public List<String> getChildren() {
		return children;
	}
	
	public void setChildren(List<String> children) {
		this.children = children;
	}
	
	public String getSpouse() {
		return spouse;
	}
	
	public void setSpouse(String spouse) {
		this.spouse = spouse;
	}
}
