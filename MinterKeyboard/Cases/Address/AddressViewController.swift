import UIKit
import MinterMy
import RxSwift
import EFQRCode
import SVProgressHUD
import AlamofireImage

enum AddressType {
	case deposit
	case donate
}

class AddressViewController: UIViewController {
	
	// MARK: - Properties.
	
	var address: String = ""
	var type: AddressType = .deposit
	
	// MARK: - Outlets.
	
	@IBOutlet weak var qrImageView: UIImageView!
	@IBOutlet weak var codeLabel: UILabel!
	@IBOutlet weak var imageCopyView: CopyView!
	@IBOutlet weak var textCopyView: CopyView!
	@IBOutlet weak var avatarImageView: UIImageView!
	@IBOutlet weak var clipboardButton: UIButton!
	@IBOutlet weak var depositLabel: UILabel!
	@IBOutlet weak var donationLabel: UILabel!
	
	// MARK: - Dispose Bag
	
	var disposeBag = DisposeBag()
	
	// MARK: - Lifecycle.
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	// MARK: - Configure
	
	func configure(type: AddressType) {
		self.type = type
	}
	
	func setup() {
		switch type {
		case .deposit:
			address = "Mx" + Session.shared.account.address
			depositLabel.isHidden = false
		case .donate:
			address = "Mx408fb7d25f40d0361ee370cff812c1fe1fac74a7"
			donationLabel.isHidden = false
		}
		
		if address.isValidAddress() {
			let avatarURL = MinterMyAPIURL.avatarAddress(address: address).url()
			avatarImageView.af_setImage(withURL: avatarURL)
		}
		
		let qr = EFQRCode.generate(content: address)
		let image = (qr != nil) ? UIImage(cgImage: qr!) : UIImage()
		
		qrImageView.image = image
		codeLabel.text = address
		imageCopyView.configure(text: address)
		textCopyView.configure(text: address)
		
		clipboardButton.rx.tap.subscribe(onNext: { (_) in
			UIPasteboard.general.string = self.address
			SVProgressHUD.showSuccess(withStatus: "COPIED")
		}).disposed(by: disposeBag)
	}
}

