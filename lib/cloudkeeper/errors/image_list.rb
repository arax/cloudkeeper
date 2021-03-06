module Cloudkeeper
  module Errors
    module ImageList
      autoload :VerificationError, 'cloudkeeper/errors/image_list/verification_error'
      autoload :RetrievalError, 'cloudkeeper/errors/image_list/retrieval_error'
      autoload :DownloadError, 'cloudkeeper/errors/image_list/download_error'
    end
  end
end
